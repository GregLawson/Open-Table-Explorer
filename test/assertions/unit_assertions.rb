###########################################################################
#    Copyright (C) 2012-2015 by Greg Lawson                                      
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../../app/models/unit.rb'
class Unit
require_relative '../../app/models/assertions.rb'
module Assertions

module ClassMethods

end #ClassMethods
end #Assertions
include Assertions
extend Assertions::ClassMethods
#self.assert_pre_conditions
module Constants
end #Constants
include Constants

module ClassMethods
extend ClassMethods
# conditions that are always true (at least atomically)
def assert_invariant
#	fail "end of assert_invariant "
end # class_assert_invariant
# conditions true while class is being defined
def assert_pre_conditions
	assert_includes(included_modules, :MiniTest)
	assert_respond_to(Unit, :new_from_path)
	assert_module_included(self, FilePattern::Assertions)
end #class_assert_pre_conditions
# assertions true after class (and nested module Examples) is defined
def assert_post_conditions
	assert_equal(TE, FilePattern::Examples::SELF)
end #class_assert_post_conditions
end #ClassMethods

module KernelMethods
end #KernelMethods
# conditions that are always true (at least atomically)
def assert_invariant
	fail "end of assert_invariant "
end #assert_invariant
# conditions true while class is being defined
# assertions true after class (and nested module Examples) is defined
def assert_pre_conditions
	refute_empty(@model_class_name, "test_class_name")
	refute_empty(@model_basename, "model_basename")
#	fail "end ofassert_pre_conditions "
end #class_assert_pre_conditions
# assertions true after class (and nested module Examples) is defined
def assert_post_conditions(message='')
	message+="\ndefault FilePattern.project_root_dir?=#{FilePattern.project_root_dir?.inspect}"
	refute_empty(@project_root_dir, message)
end #assert_post_conditions
def assert_tested_files(executable, file_patterns)
	tested_file_patterns=tested_files(executable).map do |f|
		FilePatter.find_by_path(f)[:name]
	end #map
	assert_equal(file_patterns, tested_file_patterns)
end #assert_tested_files
def assert_default_test_class_id(expected_id, message='')
	message+="self=#{self.inspect}"
	assert_equal(expected_id, default_test_class_id?, message+caller_lines)
end #default_test_class_id

module Examples
include Constants
UnboundedFixnumUnit=Unit.new(:UnboundedFixnum)
SELF=Unit.new #defaults to this unit
end #Examples
include Examples
module Assertions

module ClassMethods

end #ClassMethods
end #Assertions
end # Unit
