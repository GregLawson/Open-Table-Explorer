###########################################################################
#    Copyright (C) 2012-2017 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative '../../app/models/nomination.rb'
class NominationTest < TestCase
  # include DefaultTests
  include RailsishRubyUnit::Executable.model_class?::DefinitionalConstants
  include RailsishRubyUnit::Executable.model_class?::ReferenceObjects
  def test_context
    assert_respond_to(Nomination, :nominate, Nomination.methods(false))
    assert_include(Nomination.methods, :nominate)
    assert_respond_to(Nomination::Self, :commit, Nomination.instance_methods(false))
    assert_include(Nomination.instance_methods(false), :commit)
  end # context

  module Examples
    Self = Nomination.nominate(TestExecutable.new_from_path($PROGRAM_NAME))
  end #  Examples
  include Examples

  def setup
    @temp_repo = Repository.create_test_repository
  end # setup

  def teardown
    Repository.delete_even_nonxisting(@temp_repo.path)
    #    assert_empty(Dir[Cleanup_failed_test_paths], Cleanup_failed_test_paths)
  end # teardown

  # rubocop:disable Style/MethodName
  def test_Nomination_DefinitionalConstants
  end # DefinitionalConstants

  def test_nominate
  end # nominate

  def test_pending
    assert_instance_of(Array, Nomination.pending)
    Nomination.pending.each do |nomination|
      assert_instance_of(Nomination, nomination)
    end # each
  end # pending

  def test_dirty_unit_chunks
    pattern = FilePattern.find_from_path($PROGRAM_NAME)
    lookup = FilePattern.new_from_path($PROGRAM_NAME)
    assert_equal(:nomination, lookup.unit_base_name, lookup.inspect)

    units = Repository::This_code_repository.status.group_by do |file_status|
      assert_path_exist(file_status.file)
      pattern = FilePattern.find_from_path(file_status.file)
      #			assert_instance_of(Hash, pattern)
      if pattern.nil? # not a unit file
        :non_unit
      else
        lookup = FilePattern.new_from_path(file_status.file)
        refute_nil(lookup, file_status.explain)
        unit_name = lookup.unit_base_name
        if Unit.all_basenames.include?(unit_name)
          unit_name
        else # non-unit files
          :non_unit
        end # if
      end # if
    end # group_by
    # !		assert_equal([], units.keys, units.ruby_lines_storage)
    dirty_unit_chunks = Nomination.dirty_unit_chunks(Repository::This_code_repository)

    dirty_unit_chunks.each_pair do |unit, files|
      assert_instance_of(Array, files, dirty_unit_chunks.inspect)
      assert_instance_of(Symbol, unit, dirty_unit_chunks.ruby_lines_storage)
    end # chunk
  end # dirty_unit_chunks

  def dirty_test_executables
    assert_instance_of(Array, Nomination.dirty_test_executables)
    test_executable_chunks = Nomination.dirty_unit_chunks(Repository::This_code_repository)
		test_executable_chunks.keys do |unit_name|
      test_executable_chunks[unit_name].each do |file_status|
				if file_status.log_file?
					nil
				elsif file_status.work_tree == :ignore
					nil
				else
						test_executable = TestExecutable.new_from_path(file_status.file)
						testable = test_executable.generatable_unit_file?
						if testable
							test_executable # find unique
						end # if
				end # map
      end # if
    end # chunk
    assert_instance_of(Array, test_executables)
    test_executables.map do |test_executable|
    end # chunk
    test_executable_chunks.each do |test_executable, dirty_files|
    end # each

    Nomination.dirty_test_executables.chunk do |test_executable|
    end # partition
  end # dirty_test_executables

    def test_clean_apply
    end # clean_apply




    def test_apply
    end # apply

  def test_included_module_names
    this_class = RailsishRubyUnit::Executable.model_class?
    # !		assert_includes(this_class.included_module_names, (this_class.name + '::DefinitionalClassMethods').to_sym)
    assert_includes(this_class.included_module_names, (this_class.name + '::DefinitionalConstants').to_sym)
    # !		assert_includes(this_class.included_module_names, (this_class.name + '::Constructors').to_sym)
    assert_includes(this_class.included_module_names, (this_class.name + '::ReferenceObjects').to_sym)
    assert_includes(this_class.included_module_names, (this_class.name + '::Assertions').to_sym)
  end # included_module_names

  def test_nested_scope_modules
    this_class = RailsishRubyUnit::Executable.model_class?
    assert_includes(this_class.constants, :DefinitionalClassMethods)
    assert_includes(this_class.constants, :DefinitionalConstants)
    assert_includes(this_class.constants, :Constructors)
    assert_includes(this_class.constants, :ReferenceObjects)
    assert_includes(this_class.constants, :Assertions)
    nested_constants = this_class.constants.map do |m|
      trial_eval = eval(this_class.name.to_s + '::' + m.to_s)
      if trial_eval.is_a?(Module)
        trial_eval
      end # if
    end.compact # map

    assert_includes(nested_constants, this_class::DefinitionalClassMethods)
    assert_includes(nested_constants, this_class::DefinitionalConstants)
    assert_includes(nested_constants, this_class::Constructors)
    assert_includes(nested_constants, this_class::ReferenceObjects)
    assert_includes(nested_constants, this_class::Assertions)

    assert_includes(this_class.nested_scope_modules, this_class::DefinitionalClassMethods)
    assert_includes(this_class.nested_scope_modules, this_class::DefinitionalConstants)
    assert_includes(this_class.nested_scope_modules, this_class::Constructors)
    assert_includes(this_class.nested_scope_modules, this_class::ReferenceObjects)
    assert_includes(this_class.nested_scope_modules, this_class::Assertions)
    assert_equal(this_class::ClassInterface, Dry::Types::Struct::ClassInterface)
    # !		refute_includes(this_class.nested_scope_modules, Dry::Types::Struct::ClassInterface)
  end # nested_scope_modules

  def test_Nomination_assert_pre_conditions
    #		refute(Self.frozen?, Self.inspect)
  end # assert_pre_conditions

  def test_Nomination_assert_post_conditions
  end # assert_post_conditions

  def test_assert_pre_conditions
    assert_equal(NamedCommit::Working_tree, Self.commit, Self.inspect) # nil means working directory (to be stash)
    assert_equal(:unit, Self.test_type, Self.inspect)
    assert_equal(:nomination, Self.unit, Self.inspect)
    #		Self.assert_pre_conditions
    #		TestTestExecutable.assert_pre_conditions
  end # assert_pre_conditions

  def test_assert_post_conditions
  end # assert_post_conditions

  def test_Nomination_Examples
  end # Examples
  # rubocop:enable Style/MethodName
end # Nomination
