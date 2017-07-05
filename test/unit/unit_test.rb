###########################################################################
#    Copyright (C) 2012-2017 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../../app/models/test_environment_test_unit.rb'
require_relative '../../test/assertions/unit_assertions.rb'
# DefaultTests=eval(RailsishRubyUnit::Executable.default_tests_module_name?)
# TestCase=eval(RailsishRubyUnit::Executable.test_case_class_name?)
class UnitTest < TestCase
  # include DefaultTests
  include Unit::Examples
  def test_edit_files
    assert_instance_of(Array, Executable.edit_files)
    assert_kind_of(Pathname, Executable.edit_files[0])
  end # edit_files

  def test_not_files
    assert_instance_of(Array, Executable.not_files)
    assert_kind_of(Pathname, Executable.not_files[0])
    #	assert_equal(["/home/greg/Desktop/src/Open-Table-Explorer/script/unit.rb", "/home/greg/Desktop/src/Open-Table-Explorer/test/integration/unit_test.rb", "/home/greg/Desktop/src/Open-Table-Explorer/test/long_test/unit_test.rb", "/home/greg/Desktop/src/Open-Table-Explorer/test/unit/unit_assertions_test.rb", "/home/greg/Desktop/src/Open-Table-Explorer/log/library/unit.log", "/home/greg/Desktop/src/Open-Table-Explorer/log/assertions/unit.log", "/home/greg/Desktop/src/Open-Table-Explorer/log/integration/unit.log", "/home/greg/Desktop/src/Open-Table-Explorer/log/long/unit.log", "/home/greg/Desktop/src/Open-Table-Explorer/test/data_sources/unit"], Executable.not_files)
  end # not_files

  def test_directories
    assert_equal([], Executable.directories)
    assert_instance_of(Array, Executable.directories)
    #	assert_kind_of(Pathname, Executable.directories[0])
  end # directories

  def test_missing_files
    #	assert_equal(["/home/greg/Desktop/src/Open-Table-Explorer/script/unit.rb", "/home/greg/Desktop/src/Open-Table-Explorer/test/integration/unit_test.rb", "/home/greg/Desktop/src/Open-Table-Explorer/test/long_test/unit_test.rb", "/home/greg/Desktop/src/Open-Table-Explorer/test/unit/unit_assertions_test.rb", "/home/greg/Desktop/src/Open-Table-Explorer/log/library/unit.log", "/home/greg/Desktop/src/Open-Table-Explorer/log/assertions/unit.log", "/home/greg/Desktop/src/Open-Table-Explorer/log/integration/unit.log", "/home/greg/Desktop/src/Open-Table-Explorer/log/long/unit.log"], Executable.missing_files)
    assert_instance_of(Array, Executable.missing_files)
    assert_kind_of(Pathname, Executable.missing_files[0])
  end # missing_files

  def test_edit_symbols
    assert_equal([:model, :unit, :assertions], Executable.edit_symbols)
  end # edit_symbols

  def test_not_symbols
    assert_equal([:model, :unit, :script, :integration_test, :slowest_test, :slower_test, :interactive_test, :assertions, :assertions_test, :unit_log, :assertions_test_log, :long_log, :data_sources_dir, :integration_log], Executable.not_symbols)
  end # not_symbols

  def test_missing_symbols
    assert_equal([:script, :integration_test, :slowest_test, :slower_test, :interactive_test, :assertions_test, :unit_log, :assertions_test_log, :long_log, :data_sources_dir, :integration_log], Executable.missing_symbols)
  end # missing_symbols

  def test_new_from_path
    path = $PROGRAM_NAME
    library_name = FilePattern.unit_base_name?(path)
    assert_equal(:unit, library_name)
    unit = Unit.new(model_basename: library_name, project_root_dir: FilePattern.project_root_dir?(path))
    assert_equal(:unit, unit.model_basename)
    assert_equal(unit.model_basename, Unit.new_from_path(path).model_basename)
    assert_equal(unit.project_root_dir, Unit.new_from_path(path).project_root_dir)
    assert_equal(unit.patterns, Unit.new_from_path(path).patterns)
    assert_equal(unit, Unit.new_from_path(path)) # value object?
    assert_equal(:minimal4, FilePattern.unit_base_name?('test/unit/minimal4_assertions_test.rb'))
    assert_equal(:minimal4, UnitWithAssertions.model_basename)
  end # new_from_path

  def test_unit_names?
    assert_equal(['unit'], Unit.unit_names?([$PROGRAM_NAME]))
  end # unit_names?

  def test_patterned_files
    assert_includes(Unit.patterned_files, $PROGRAM_NAME)
  end # patterned_files

  def test_all
    assert_includes(Unit.all, Unit::Executable)
  end # all

  def test_all_basenames
    assert_include(FileUnit.all_basenames, :unit)
  end # all_basenames

  def test_data_source_directories
    assert_equal('test/data_sources/', Unit.data_source_directories)
  end # data_source_directory?

  def test_equals
    assert(Unit.new == Unit.new)
  end #==

  def test_data_source_directory?
    assert_equal('/home/greg/Desktop/src/Open-Table-Explorer/', Unit::Executable.project_root_dir, Unit::Executable.inspect)
    assert_equal('/home/greg/Desktop/src/Open-Table-Explorer/test/data_sources/', Unit::Executable.project_root_dir + Unit.data_source_directories)
    assert_equal('/home/greg/Desktop/src/Open-Table-Explorer/test/data_sources/unit/', Unit::Executable.project_root_dir + Unit.data_source_directories + Unit::Executable.model_basename.to_s + '/')
    assert_equal('/home/greg/Desktop/src/Open-Table-Explorer/test/data_sources/unit/', Unit::Executable.data_source_directory?)
  end # data_source_directory?

  def test_pathname_pattern?
  end # pathname_pattern

  def test_data_sources_directory
    message = 'Unit::Executable.data_sources_directory?=' + Unit::Executable.data_sources_directory? + "\n"
    message += 'Dir[Unit::Executable.data_sources_directory?]=' + Dir[Unit::Executable.data_sources_directory?].inspect + "\n"
    refute_empty(Unit::Executable.data_sources_directory?, message)
    assert_empty(Dir[Unit::Executable.data_sources_directory? + '/*'], message)
    related_file = Unit.new_from_path('test/unit/tax_form_test.rb')
    message = 'related_file=' + related_file.inspect + "\n"
    message += 'related_file.data_sources_directory?=' + related_file.data_sources_directory? + "\n"
    message += 'Dir[related_file.data_sources_directory?]=' + Dir[related_file.data_sources_directory?].inspect + "\n"
    refute_empty(Dir[related_file.data_sources_directory?], message)
  end # data_sources_directory

  def test_pathnames
    assert_instance_of(Array, UnitWithAssertions.pathnames?)
    assert_operator(5, :<=, UnitWithAssertions.pathnames?.size)
    #	assert_array_of(UnitWithAssertions.pathnames?, String)
    pathnames = FilePattern::Patterns.map do |p|
      UnitWithAssertions.	pathname_pattern?(p[:name])
    end # map
    assert_equal(UnitWithAssertions.pathnames?, pathnames)
    Executable # .assert_pre_conditions
    Executable # .assert_post_conditions
    assert_includes(Executable.pathnames?, File.expand_path($PROGRAM_NAME), Executable)
  end # pathnames
end # Unit

require_relative '../../app/models/default_test_case.rb'

class RubyUnitTest < TestCase
  include Unit::Examples
  def test_assertions_pathname
    #	assert(File.exists?(Executable.assertions_pathname?))
    assert_data_file(Executable.assertions_pathname?)
  end # assertions_pathname?

  def test_assertions_test_pathname
    refute_nil('UnitWithAssertions' + '_assertions_test.rb', UnitWithAssertions.inspect)
    refute_nil(UnitWithAssertions.assertions_test_pathname?)
    refute_equal('', '../../test/unit/' + 'UnitWithAssertions' + '_assertions_test.rb', UnitWithAssertions.inspect)
    assert(File.exist?(UnitWithAssertions.assertions_test_pathname?), UnitWithAssertions.inspect)
    assert_data_file(UnitWithAssertions.assertions_test_pathname?)
  end # assertions_test_pathname?

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
    test_case = eval('DefaultTestCase' + default_test_class_id.to_s)
    tests = eval('DefaultTests' + default_test_class_id.to_s)
    # till split	assert_equal(2, default_test_class_id, te.inspect)
    # till split	assert_equal(2, Unit.new(te.model_name?).default_test_class_id?, te.inspect)
    #	assert_equal(1, Unit.new('DefaultTestCase').default_test_class_id?)
  end # default_test_class_id

	def test_test_types
		test_directories = Dir['test/*']
		test_types = test_directories.map {|directory_path| directory_path[5..-1].to_sym}
		test_types -= [:assertions, :data_sources, :fixtures, :'assertions.rb'] # not tests
		test_types += [:script]
		assert_equal([:slowest, :slower, :interactive, :unit, :integration, :assertions, :script], test_types)
		assert_equal(test_types, Unit.test_types)
	end # test_types
	
  def test_parallel_display
    parallel_display = UnitWithAssertions.parallel_display
    assert_instance_of(Hash, parallel_display)
    parallel_display.each_pair do |symbol, parallel_symbol|
      assert_includes(FilePattern::Patterns.map { |pattern| pattern[:name] }, symbol)
      assert_includes(FilePattern::Patterns.map { |pattern| pattern[:name] }, parallel_symbol)
    end # map

    edit_files = UnitWithAssertions.edit_files
    refute_empty(edit_files, UnitWithAssertions.inspect)
    edit_files.map do |file|
      assert_data_file(file)
      symbol = FilePattern.find_name_from_path(file)
      parallel_symbol = UnitWithAssertions.parallel_display[symbol]
      if parallel_symbol.nil?
        nil
      else
        assert_instance_of(Symbol, parallel_symbol)
        assert_includes(FilePattern::Patterns.map { |pattern| pattern[:name] }, parallel_symbol, symbol)
        parallel_file = UnitWithAssertions.pathname_pattern?(parallel_symbol)
        assert_data_file(parallel_file)
      end # if
    end.compact # map
    assert_operator(Executable.parallel_display.size, :>=, 1)
    assert_operator(Executable.parallel_display.size, :<=, 6)
  end # parallel_display

  def test_tested_files
    executable = Executable.pathname_pattern?(:unit)
    tested_files = Executable.tested_files(executable)
    assert_operator(Executable.default_test_class_id?, :<=, tested_files.size)
  end # tested_files

	def test_tested_symbols
    assert_equal([:model, :unit], Executable.tested_symbols(:unit))
    assert_equal([:model, :script], Executable.tested_symbols(:script))
#!    assert_equal([:model, :assertions], Executable.tested_symbols(:assertions))
    assert_equal([:model, :integration_test], Executable.tested_symbols(:integration_test))
    assert_equal([:assertions, :assertions_test, :model], Executable.tested_symbols(:assertions_test))
	end # tested_symbols
	
  def test_compare
    assert_equal(0, Not_unit <=> Not_unit)
    assert_equal(nil, Not_rooted <=> Not_rooted) # never happen in real life?
    assert_nil(Not_unit.model_basename)
    assert_nil(Not_rooted.model_basename)
    assert_equal(+1, Not_unit <=> Not_rooted)
    assert_equal(-1, Not_rooted <=> Not_unit)
    #	assert_equal(+1, Not_unit.project_root_dir <=> Not_rooted.project_root_dir)
    assert_equal(0, Executable <=> Executable)
    assert_equal(0, TestMinimal <=> TestMinimal)

    assert_equal(-1, Not_rooted <=> Not_unit)
    assert_equal(nil, Not_rooted <=> Not_rooted)
    assert_equal(-1, Not_rooted <=> Executable)
    assert_equal(-1, Not_rooted <=> TestMinimal)

    assert_equal(0, Not_unit <=> Not_unit)
    assert_equal(+1, Not_unit <=> Not_rooted)
    assert_equal(-1, Not_unit <=> Executable)
    assert_equal(-1, Not_unit <=> TestMinimal)

    assert_equal(+1, Executable <=> Not_unit)
    assert_equal(+1, Executable <=> Not_rooted)
    assert_equal(0, Executable <=> Executable)

    assert_equal(+1, Executable.model_basename <=> TestMinimal.model_basename)
    assert_equal(+1, Executable <=> TestMinimal)

    assert_equal(+1, TestMinimal <=> Not_unit)
    assert_equal(+1, TestMinimal <=> Not_rooted)
    assert_equal(-1, TestMinimal <=> Executable)
    assert_equal(0, TestMinimal <=> TestMinimal)
  end # <=>

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
    Executable # .assert_pre_conditions
  end # values

  def test_Examples
    refute_nil(Executable.model_basename)
    refute_nil(Executable.project_root_dir)
    refute_nil(TestMinimal.model_basename)
    refute_nil(TestMinimal.project_root_dir)
    assert_nil(Not_unit.model_basename)
    refute_nil(Not_unit.project_root_dir)
    assert_nil(Not_rooted.model_basename)
    assert_nil(Not_rooted.project_root_dir)
    refute_empty(FilePattern.project_root_dir?)
    refute_empty(Not_rooted.project_root_dir)
    refute_empty(Executable.project_root_dir)
    refute_empty(TestMinimal.project_root_dir)
    refute_empty(Not_unit.project_root_dir)
  end # Examples
end # Unit

class RubyUnitTest < TestCase
  def test_RubyUnit_virtus_values
  end # values

  def test_default_tests_module_name?
    assert_equal(:DefaultTests0, RubyUnit::Self.default_tests_module_name?)
  end # default_tests_module?

  def test_case_class_name?
    assert_equal(:RubyUnitTest, RubyUnit::Self.test_class_name)
  end # test_case_class?

  def test_test_class_name
    assert_equal(:ruby_unit, RubyUnit::Self.model_basename)
    assert_equal(:RubyUnit, RubyUnit::Self.model_class_name)
    assert_equal(:RubyUnitTest, RubyUnit::Self.test_class_name)
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
        { enumerator: :ancestors, module: ancestor, method: ancestral_method }
      end # map
    end # map
    module_methods = RubyUnit::Executable.class.included_modules.map do |ancestor|
      ancestor.instance_methods.map do |ancestral_method|
        { enumerator: :included_modules, module: ancestor, method: ancestral_method }
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
  end # Constants
end # RubyUnit

class RailsishRubyUnitTest < TestCase
  include RailsishRubyUnit::Examples
  def test_Constants
    assert_instance_of(RailsishRubyUnit, RailsishRubyUnit::Executable)
    assert_respond_to(RailsishRubyUnit, :new_from_path)
    assert_respond_to(RailsishRubyUnit::Executable, :model_class_name)
    assert_equal(:Unit, RailsishRubyUnit::Executable.model_class_name)
  end # Constants

  def test_model_class
    assert_equal(Unit, RailsishRubyUnit::Executable.model_class?)
  end # model_class

  def test_model_name
    assert_equal(:Unit, RailsishRubyUnit::Executable.model_class_name)
    assert_equal(:Unit, RailsishRubyUnit::Executable.model_name?)
  end # model_name?

  def test_test_class_name
  end # test_class

  def test_test_class
  end # test_class

  def test_create_test_class
  end # create_test_class

  def test_model_pathname
    message = 'Executable = ' + RailsishRubyUnitTest::Executable.inspect
    message += "\n" + 'Executable.model_pathname? = ' + RailsishRubyUnit::Executable.model_pathname?
    assert(File.exist?(RailsishRubyUnit::Executable.model_pathname?), message)
    assert_data_file(RailsishRubyUnit::Executable.model_pathname?, message)
  end # model_pathname?

  def test_model_test_pathname
    assert(File.exist?(RailsishRubyUnit::Executable.model_test_pathname?))
    assert_data_file(RailsishRubyUnit::Executable.model_test_pathname?)
  end # model_test_pathname?

  def test_Unit_assert_pre_conditions
    Unit.assert_pre_conditions
  end # class_assert_pre_conditions

  def test_Unit_assert_post_conditions
    Unit.assert_post_conditions
  end # class_assert_post_conditions

  def test_assert_pre_conditions
  end # class_assert_pre_conditions

  def test_assert_post_conditions
  end # assert_post_conditions

  def test_assert_tested_files
  end # assert_tested_files

  def test_assert_default_test_class_id
    #	Unit.assert_constant_path_respond_to(:TestIntrospection, :Unit, :KernelMethods, :assert_default_test_class_id)
    #	assert_respond_to(UnitTest, :assert_default_test_class_id)
    #	explain_assert_respond_to(self, :assert_default_test_class_id)
    Unit.new(:UnitWithAssertions).assert_default_test_class_id(4, '')
    # til split	Unit.new(:Unit).assert_default_test_class_id(2,'')
    Unit.new(:DefaultTestCase).assert_default_test_class_id(2, '')
    Unit.new(:EmptyDefaultTest).assert_default_test_class_id(0, '')
    Unit.new(:GenericType).assert_default_test_class_id(3, '')
  end # default_test_class_id

  def test_Examples
    UnitWithAssertions.assert_pre_conditions
    UnitWithAssertions.assert_post_conditions
  end # Examples
end # UnitTest

class RailsUnitTest < TestCase
  include RailsUnit::Examples
  def test_RailsUnit_initialize
    assert_equal('code_base', Odd_plural_executable.singular_table)
    assert_equal('code_bases', Odd_plural_executable.plural_table)
    assert_equal(:code_base, Odd_plural_executable.unit?.model_class_name, Odd_plural_executable.inspect)
    assert_equal(:code_base, Odd_plural_executable.unit?.model_class_name.to_s.underscore.to_sym, Odd_plural_executable.inspect)

    assert_equal(:code_base, Odd_plural_executable.unit?.model_basename, Odd_plural_executable.inspect)
    assert_equal(:unit, Odd_plural_executable.test_type)
  end # RailsUnit

  def test_test_file?
    assert_equal('test/unit/code_base_test.rb', Odd_plural_executable.test_file?)
  end # test_file?

  def test_Examples
    assert_equal(:unit, Unit_executable.test_type)
    assert_equal(:unit, Plural_executable.test_type)
    assert_equal(:unit, Singular_executable.test_type)
    assert_equal(:unit, Odd_plural_executable.test_type)
  end # Examples
end # RailsUnit

class ExampleTest < TestCase
  include Example::Examples
  def test_find_all_in_class
    assert_includes(Example.find_all_in_class(Unit), TestMinimal_Example)
  end # find_all_in_class

  def test_find_by_class
    assert_includes(Example.find_by_class(Unit, Unit), TestMinimal_Example)
  end # find_by_class

  def test_Example_virtus
    assert_equal(Unit, TestMinimal_Example.containing_class)
    assert_equal(:TestMinimal, TestMinimal_Example.example_constant_name)
  end # values

  def test_equal
    assert_equal(TestMinimal_Example, TestMinimal_Example)
  end # ==

  def test_fully_qualified_name
    assert_equal('Unit::Examples::TestMinimal', TestMinimal_Example.fully_qualified_name)
  end # fully_qualified_name

  def test_value
    assert_equal(Unit::TestMinimal, TestMinimal_Example.value)
  end # value

  def test_Example_Examples
  end # Examples
end # Example
