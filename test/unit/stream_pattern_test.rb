###########################################################################
#    Copyright (C) 2011 by Greg Lawson                                      
#    <GregLawson@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'test_helper'
# executed in alphabetical orer? Longer names sort later.
# place in order from low to high level and easy pass to harder, so that first fail is likely the cause.
# move passing tests toward end
class StreamPatternTest < ActiveSupport::TestCase
def setup
	@testURL='http://192.168.3.193/api/LiveData.xml'
	define_model_of_test # allow generic tests
	assert_module_included(@model_class,Generic_Table)
	explain_assert_respond_to(@model_class.new,:sequential_id?,"#{@model_name}.rb probably does not include include Generic_Table statement.")
	assert_respond_to(@model_class.new,:sequential_id?,"#{@model_name}.rb probably does not include include Generic_Table statement.")
	define_association_names
end #def
def test_general_associations
	assert_general_associations(@table_name)
end #test
def test_id_equal
	if @model_class.new.sequential_id? then
	else
		@my_fixtures.each_value do |ar_from_fixture|
			message="Check that logical key (#{ar_from_fixture.logical_primary_key}) value (#{ar_from_fixture.logical_primary_key_value}) exactly matches yaml label for record."
			message+=" identify != id. ar_from_fixture.inspect=#{ar_from_fixture.inspect} ar_from_fixture.logical_primary_key_value=#{ar_from_fixture.logical_primary_key_value}"
			assert_equal(Fixtures::identify(ar_from_fixture.logical_primary_key_value),ar_from_fixture.id,message)
		end
	end
end #def
def test_specific__stable_and_working
	assert_equal(@my_fixtures,fixtures(@table_name))	
end #test
def test_aaa_test_new_assertions_ # aaa to output first
	@stream_pattern=StreamPattern.find_by_name('Acquisition')
	assert_equal('Acquisition',@stream_pattern.name)
	assert_not_nil(@stream_pattern.id)
	@fullTable=StreamPatternArgument.all
	assert_equal(2,@fullTable.size)
	#~ puts "@stream_pattern.id=#{@stream_pattern.id}"
	#~ puts "@fullTable=#{@fullTable.inspect}"
	@association=StreamPatternArgument.find_all_by_stream_pattern_id(@stream_pattern.id )
	assert_equal(2,@association.size)

	if Generic_Table.is_generic_table?(@stream_pattern.class.name) then 
		assert(@stream_pattern.class.is_matching_association?(:stream_pattern_arguments))
		assert_equal(:to_many,@stream_pattern.class.association_to_type(:stream_pattern_arguments)) 
		assert_equal(:has_many,@stream_pattern.class.association_macro_type(:stream_pattern_arguments)) 
		assert_equal(:to_many_has_many,@stream_pattern.class.association_type(:stream_pattern_arguments) )
#		assert_equal("Association stream_pattern_arguments with foreign key stream_pattern_id is empty; but belongs_to.",@stream_pattern.association_state(:stream_pattern_arguments) )
		if @stream_pattern.association_has_data(:stream_pattern_arguments) then 
			if StreamPatternArgument.find_all_by_stream_pattern_id(@stream_pattern.id ) then 
				StreamPatternArgument.find_all_by_stream_pattern_id(@stream_pattern.id )
			else
				StreamPatternArgument.all
			end #if 
			#~ puts @stream_pattern.stream_pattern_arguments.inspect
			system(@stream_pattern.class.association_grep('has_many',:stream_pattern_arguments))
			system(StreamPatternArgument.association_grep('belongs_to',:stream_patterns)) 
		end #if 
	end #if 
end #test

end #class
