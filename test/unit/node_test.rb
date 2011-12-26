###########################################################################
#    Copyright (C) 2011 by Greg Lawson                                      
#    <GregLawson@gmail.com>                                                             
#
# Copyright: See COPYING pathname that comes with this distribution
#
###########################################################################
require 'test/test_helper'
# executed in alphabetical order. Longer names sort later.
# place in order from low to high level and easy pass to harder, so that first fail is likely the cause.
# move passing tests toward end
class NodeTest < ActiveSupport::TestCase
@@test_name=self.name
@@model_name=@@test_name.sub(/Test$/, '').sub(/Controller$/, '')
@@table_name=@@model_name.tableize
 
fixtures @@table_name.to_sym
def setup
	@testURL='http://192.168.3.193/api/LiveData.xml'
	define_model_of_test # allow generic tests
	assert_module_included(@model_class,Generic_Table)
	explain_assert_respond_to(@model_class,:sequential_id?,"#{@model_name}.rb probably does not include include Generic_Table statement. Sequential id is a class method.")
	assert_respond_to(@model_class,:sequential_id?,"#{@model_name}.rb probably does not include include Generic_Table statement.")
	define_association_names
end #setup
def test_general_associations
#more fixtures need to be loaded?	assert_general_associations(@table_name)
end #test
def test_id_equal
	if @model_class.sequential_id? then
	else
		@my_fixtures.each_value do |ar_from_fixture|
			message="Check that logical key (#{ar_from_fixture.logical_primary_key}) value (#{ar_from_fixture.logical_primary_key_value}) exactly matches yaml label for record."
			message+=" identify != id. ar_from_fixture.inspect=#{ar_from_fixture.inspect} ar_from_fixture.logical_primary_key_value=#{ar_from_fixture.logical_primary_key_value}"
			assert_equal(Fixtures::identify(ar_from_fixture.logical_primary_key_value),ar_from_fixture.id,message)
		end
	end
end #id_equal
def test_specific__stable_and_working
end #specific__stable_and_working
def test_aaa_test_new_assertions_ # aaa to output first
	assert_equal(fixtures(@table_name), @my_fixtures)
	assert_association(Node,:branch)
	assert_association(Node,:parent)
end #aaa_test_new_assertions
def test_handle_polymorphic
	class_reference=Node
	association_reference=:branch
	association_type=class_reference.association_arity(association_reference)
	assert_not_nil(association_type)
	assert_include(association_type,[:to_one,:to_many])
	assert_association(class_reference,association_reference)
	assert_equal("belongs_to :branch , :polymorphic => true\n", class_reference.association_grep(ActiveRecord::Base::ASSOCIATION_MACRO_PATTERN, association_reference))
	assert_equal(:belongs_to, class_reference.association_macro_type(association_reference))
	assert_belongs_to_association(class_reference,association_reference)
	assert(class_reference.belongs_to_association?(association_reference))
	assert_include(association_reference.to_s,class_reference.foreign_key_association_names)
	assert_equal(:to_one_belongs_to,class_reference.association_type(association_reference))
end #handle_polymorphic
end #class
