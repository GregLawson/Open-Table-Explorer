###########################################################################
#    Copyright (C) 2013-2016 by Greg Lawson                                      
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment' # avoid recursive requires
require_relative '../../app/models/default_test_case.rb'
require_relative '../../test/assertions/unit_assertions.rb'
DefaultTests=eval(RailsishRubyUnit::Executable.default_tests_module_name?)
#TestCase=eval(RailsishRubyUnit::Executable.test_case_class_name?)
class UnitTest < TestCase
#include DefaultTests
include Unit::Examples
def test_edit_files
	assert_equal(["/home/greg/Desktop/src/Open-Table-Explorer/app/models/unit.rb", "/home/greg/Desktop/src/Open-Table-Explorer/test/unit/unit_test.rb", "/home/greg/Desktop/src/Open-Table-Explorer/test/assertions/unit_assertions.rb"], Executable.edit_files)
end # edit_files
def test_not_files
	assert_equal(["/home/greg/Desktop/src/Open-Table-Explorer/script/unit.rb", "/home/greg/Desktop/src/Open-Table-Explorer/test/integration/unit_test.rb", "/home/greg/Desktop/src/Open-Table-Explorer/test/long_test/unit_test.rb", "/home/greg/Desktop/src/Open-Table-Explorer/test/unit/unit_assertions_test.rb", "/home/greg/Desktop/src/Open-Table-Explorer/log/library/unit.log", "/home/greg/Desktop/src/Open-Table-Explorer/log/assertions/unit.log", "/home/greg/Desktop/src/Open-Table-Explorer/log/integration/unit.log", "/home/greg/Desktop/src/Open-Table-Explorer/log/long/unit.log", "/home/greg/Desktop/src/Open-Table-Explorer/test/data_sources/unit"], Executable.not_files)
end # not_files
def test_directories
	assert_equal([], Executable.directories)
end # directories
def test_missing_files
	assert_equal(["/home/greg/Desktop/src/Open-Table-Explorer/script/unit.rb", "/home/greg/Desktop/src/Open-Table-Explorer/test/integration/unit_test.rb", "/home/greg/Desktop/src/Open-Table-Explorer/test/long_test/unit_test.rb", "/home/greg/Desktop/src/Open-Table-Explorer/test/unit/unit_assertions_test.rb", "/home/greg/Desktop/src/Open-Table-Explorer/log/library/unit.log", "/home/greg/Desktop/src/Open-Table-Explorer/log/assertions/unit.log", "/home/greg/Desktop/src/Open-Table-Explorer/log/integration/unit.log", "/home/greg/Desktop/src/Open-Table-Explorer/log/long/unit.log"], Executable.missing_files)
end # missing_files
def test_new_from_path
	path = $0
	library_name = FilePattern.unit_base_name?(path)
	assert_equal(:unit, library_name)	
	unit = Unit.new(model_basename: library_name, project_root_dir: FilePattern.project_root_dir?(path))
	assert_equal(:unit, unit.model_basename)	
	assert_equal(unit.model_basename, Unit.new_from_path(path).model_basename)
	assert_equal(unit.project_root_dir, Unit.new_from_path(path).project_root_dir)
	assert_equal(unit.patterns, Unit.new_from_path(path).patterns)
	assert_equal(:minimal4, FilePattern.unit_base_name?('test/unit/minimal4_assertions_test.rb'))
	assert_equal(:minimal4, UnitWithAssertions.model_basename)
end # new_from_path

def test_unit_names?
	assert_equal(['unit'], Unit.unit_names?([$0]))	
end #unit_names?
def test_patterned_files
	assert_includes(Unit.patterned_files, $0)
end # patterned_files
def test_all
	assert_includes(Unit.all, Unit::Executable)
end # all
def test_all_basenames
end # all_basenames
def test_data_source_directories?
	assert_equal('test/data_sources/', Unit.data_source_directories?)
end #data_source_directory?
def test_equals
	assert(Unit.new==Unit.new)
end #==
def test_data_source_directory?
	assert_equal('/home/greg/Desktop/src/Open-Table-Explorer/', Unit::Executable.project_root_dir)
	assert_equal('/home/greg/Desktop/src/Open-Table-Explorer/test/data_sources/', Unit::Executable.project_root_dir + Unit.data_source_directories?)
	assert_equal('/home/greg/Desktop/src/Open-Table-Explorer/test/data_sources/unit/', Unit::Executable.project_root_dir + Unit.data_source_directories? + Unit::Executable.model_basename.to_s + '/')
	assert_equal('/home/greg/Desktop/src/Open-Table-Explorer/test/data_sources/unit/', Unit::Executable.data_source_directory?)
end # data_source_directory?
def test_pathname_pattern?
end # pathname_pattern
def test_data_sources_directory
	message='Unit::Executable.data_sources_directory?='+Unit::Executable.data_sources_directory?+"\n"
	message+='Dir[Unit::Executable.data_sources_directory?]='+Dir[Unit::Executable.data_sources_directory?].inspect+"\n"
	refute_empty(Unit::Executable.data_sources_directory?, message)
	refute_empty(Dir[Unit::Executable.data_sources_directory?], message)
	related_file=Unit.new_from_path('test/unit/tax_form_test.rb')
	message='related_file='+related_file.inspect+"\n"
	message+='related_file.data_sources_directory?='+related_file.data_sources_directory?+"\n"
	message+='Dir[related_file.data_sources_directory?]='+Dir[related_file.data_sources_directory?].inspect+"\n"
	refute_empty(Dir[related_file.data_sources_directory?], message)
end #data_sources_directory
def test_pathnames
	assert_instance_of(Array, UnitWithAssertions.pathnames?)
	assert_operator(5, :<=, UnitWithAssertions.pathnames?.size)
#	assert_array_of(UnitWithAssertions.pathnames?, String)
	pathnames=FilePattern::Patterns.map do |p|
		UnitWithAssertions.		pathname_pattern?(p[:name])
	end #map
	assert_equal(UnitWithAssertions.pathnames?, pathnames)
	Executable #.assert_pre_conditions
	Executable #.assert_post_conditions
	assert_includes(Executable.pathnames?, File.expand_path($0), Executable)
end #pathnames
end # Unit

class RubyUnitTest < TestCase
include Unit::Examples
def test_assertions_pathname
#	assert(File.exists?(Executable.assertions_pathname?))
	assert_data_file(Executable.assertions_pathname?)
end #assertions_pathname?
def test_assertions_test_pathname
	refute_nil("UnitWithAssertions"+"_assertions_test.rb", UnitWithAssertions.inspect)
	refute_nil(UnitWithAssertions.assertions_test_pathname?)
	refute_equal('', "../../test/unit/"+"UnitWithAssertions"+"_assertions_test.rb", UnitWithAssertions.inspect)
	assert(File.exists?(UnitWithAssertions.assertions_test_pathname?), UnitWithAssertions.inspect)
	assert_data_file(UnitWithAssertions.assertions_test_pathname?)
end #assertions_test_pathname?
def test_default_test_class_id
	assert_path_to_constant(:DefaultTestCase0)
	assert_path_to_constant(:DefaultTestCase1)
	assert_path_to_constant(:DefaultTestCase2)
	assert_path_to_constant(:DefaultTestCase3)
	assert_path_to_constant(:DefaultTestCase4)
	assert_path_to_constant(:DefaultTests0)
	assert_path_to_constant(:DefaultTests1)
	assert_path_to_constant(:DefaultTests2)
	assert_path_to_constant(:DefaultTests3)
	assert_path_to_constant(:DefaultTests4)
	assert_equal(4, UnitWithAssertions.default_test_class_id?, UnitWithAssertions.edit_files.inspect)
	default_test_class_id = Executable.default_test_class_id?
	test_case=eval("DefaultTestCase"+default_test_class_id.to_s)
	tests = eval("DefaultTests"+default_test_class_id.to_s)
#till split	assert_equal(2, default_test_class_id, te.inspect)
#till split	assert_equal(2, Unit.new(te.model_name?).default_test_class_id?, te.inspect)
#	assert_equal(1, Unit.new('DefaultTestCase').default_test_class_id?)
end #default_test_class_id
def test_default_tests_module_name
end #default_tests_module?
def test_test_case_class_name
end #test_case_class?
def test_functional_parallelism
	pairs = [
	[Executable.pathname_pattern?(:model), Executable.pathname_pattern?(:unit)],
	[Executable.assertions_pathname?, Executable.pathname_pattern?(:unit)],
	[Executable.pathname_pattern?(:unit), Executable.pathname_pattern?(:integration_test)],
	[Executable.assertions_pathname?, Executable.assertions_test_pathname?]
	]
	pairs.select do |fp|
		refute_nil(fp, pairs.inspect)
		fp - Executable.edit_files==[] # files must exist to be edited?
	end #map
	edit_files = Executable.edit_files
	assert_operator(Executable.functional_parallelism(edit_files).size, :>=, 1)
	assert_operator(Executable.functional_parallelism(edit_files).size, :<=, 4)
end #functional_parallelism
def test_tested_files
	executable = Executable.pathname_pattern?(:unit)
	tested_files = Executable.tested_files(executable)
	assert_operator(Executable.default_test_class_id?, :<=, tested_files.size)
end #tested_files
def test_Unit
	assert_respond_to(Unit::Executable, :model_basename)
	assert_equal(:unit, Unit::Executable.model_basename)	
	assert_equal(:minimal4, UnitWithAssertions.model_basename)
	model_class_name = FilePattern.path2model_name?
	assert_equal(:Unit, model_class_name)
	project_root_dir = FilePattern.project_root_dir?
	assert_equal(:Unit, RubyUnit::Executable.model_class_name)
	assert_equal(:unit, RubyUnit::Executable.model_basename)
	refute_empty(RubyUnit::Executable.project_root_dir)
	Executable #.assert_pre_conditions
end # values
end # Unit
class RubyUnitTest < TestCase
def test_test_class_name
end # test_class_name
def test_test_class
end # test_class
def test_create_test_class
end # create_test_class
def test_Constants
	assert_instance_of(RubyUnit, RubyUnit::Executable)
	assert_respond_to(RubyUnit, :new_from_path)
	ancestor_classes = RubyUnit::Executable.class.ancestors
	assert_includes(ancestor_classes, RubyUnit)
	ancestral_methods = ancestor_classes.map do |ancestor|
		ancestor.instance_methods.map do |ancestral_method|
		{enumerator: :ancestors, module: ancestor, method: ancestral_method}
		end # map
	end # map
	module_methods = RubyUnit::Executable.class.included_modules.map do |ancestor|
		ancestor.instance_methods.map do |ancestral_method|
		{enumerator: :included_modules, module: ancestor, method: ancestral_method}
		end # map
	end # map
	message = (ancestral_methods + module_methods).map do |ancestor| 
		ancestor.map do |ancestral_method| 
			ancestral_method[:module].to_s + '#' + ancestral_method[:method].to_s
		end # map
	end.join("\n") # map
	assert_includes(RubyUnit::Executable.methods, :model_class_name, message)
#	assert_includes(RubyUnit::Executable.methods(false), :model_class_name)
	assert_equal(:Unit, RubyUnit::Executable.model_class_name)
end #Constants
end # RubyUnit

class RailsishRubyUnitTest < TestCase
include RailsishRubyUnit::Examples
def test_Constants
	assert_instance_of(RailsishRubyUnit, RailsishRubyUnit::Executable)
	assert_respond_to(RailsishRubyUnit, :new_from_path)
	assert_respond_to(RailsishRubyUnit::Executable, :model_class_name)
	assert_equal(:Unit, RailsishRubyUnit::Executable.model_class_name)
end #Constants
def test_model_class
	assert_equal(Unit, RailsishRubyUnit::Executable.model_class?)
end #model_class
def test_model_name
	assert_equal(:Unit, RailsishRubyUnit::Executable.model_name?)
end #model_name?
def test_model_pathname
	message = 'Executable = ' + RailsishRubyUnitTest::Executable.inspect
	message += "\n" + 'Executable.model_pathname? = ' + RailsishRubyUnit::Executable.model_pathname?
	assert(File.exists?(RailsishRubyUnit::Executable.model_pathname?), message)
	assert_data_file(RailsishRubyUnit::Executable.model_pathname?, message)
end #model_pathname?
def test_model_test_pathname
	assert(File.exists?(RailsishRubyUnit::Executable.model_test_pathname?))
	assert_data_file(RailsishRubyUnit::Executable.model_test_pathname?)
end #model_test_pathname?
def test_Unit_assert_pre_conditions
	Unit #.assert_pre_conditions
end #class_assert_pre_conditions
def test_Unit_assert_post_conditions
	Unit #.assert_post_conditions
end #class_assert_post_conditions
def test_assert_pre_conditions
end #class_assert_pre_conditions
def test_assert_post_conditions
end #assert_post_conditions
def test_assert_tested_files
end #assert_tested_files
def test_assert_default_test_class_id
#	Unit.assert_constant_path_respond_to(:TestIntrospection, :Unit, :KernelMethods, :assert_default_test_class_id)
#	assert_respond_to(UnitTest, :assert_default_test_class_id)
#	explain_assert_respond_to(self, :assert_default_test_class_id)
	UnitWithAssertions #.assert_default_test_class_id(4,'')
#til split	Unit.new(:Unit).assert_default_test_class_id(2,'')
#	Unit.new(:DefaultTestCase) #.assert_default_test_class_id(2,'')
#	Unit.new(:EmptyDefaultTest) #.assert_default_test_class_id(0,'')
#	Unit.new(:GenericType) #.assert_default_test_class_id(3,'')
end #default_test_class_id
def test_Examples
	UnitWithAssertions #.assert_pre_conditions
	UnitWithAssertions #.assert_post_conditions
end #Examples
end # UnitTest

class RailsUnitTest < TestCase
include RailsUnit::Examples
def test_RailsUnit_initialize
	assert_equal('code_base', Odd_plural_executable.singular_table)
	assert_equal('code_bases', Odd_plural_executable.plural_table)
#	assert_equal(:code_base, Odd_plural_executable.unit?.model_class_name, Odd_plural_executable.inspect)
#	assert_equal(:code_base, Odd_plural_executable.unit?.model_class_name.to_s.underscore.to_sym, Odd_plural_executable.inspect)

#	assert_equal(:code_base, Odd_plural_executable.unit?.model_basename, Odd_plural_executable.inspect)
#	assert_equal(:unit, Odd_plural_executable.test_type)
end # RailsUnit
def test_test_file?
	assert_equal('test/unit/code_base_test.rb',Odd_plural_executable.test_file?)
end #test_file?
def test_Examples
	assert_equal(:unit, Unit_executable.test_type)
	assert_equal(:unit, Plural_executable.test_type)
	assert_equal(:unit, Singular_executable.test_type)
	assert_equal(:unit, Odd_plural_executable.test_type)
end # Examples
end # RailsUnit

class ExampleTest < TestCase
def test_find_all_in_class
end # find_all_in_class
def test_find_by_class
end # find_by_class
def test_equal
end # ==
def test_fully_qualified_name
end # fully_qualified_name
def test_value
end # value
end # Example
