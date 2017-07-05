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
  def test_Nomination_attributes
		Nomination.assert_pre_conditions
  end # attributes


  def test_nominate
    refute_nil(Nomination::Self.changes_commit, Nomination::Self.inspect)
  end # nominate

  def test_dirty_unit_chunks
    pattern = FilePattern.find_from_path($PROGRAM_NAME)
    lookup = FilePattern.new_from_path($PROGRAM_NAME)
    assert_equal(:nomination, lookup.unit_base_name, lookup.inspect)

    units = Repository::This_code_repository.status.group_by do |file_status|
#!      assert_path_exist(file_status.file)
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

  def test_dirty_test_executables
    assert_instance_of(Array, Nomination.dirty_test_executables(@temp_repo))
		repository = Repository::This_code_repository
    dirty_unit_chunks = Nomination.dirty_unit_chunks(repository)
		test_executables = dirty_unit_chunks.keys.map do |unit_name|
			assert_instance_of(Symbol, unit_name)
			assert_include(Unit.all_basenames << :non_unit, unit_name, dirty_unit_chunks.ruby_lines_storage)
      dirty_unit_chunks[unit_name].map do |file_status|
				assert_instance_of(FileStatus, file_status)
				message = unit_name.inspect
				if file_status.log_file? 
					if dirty_unit_chunks[unit_name].size == 1
						puts 'log_file? : ' + dirty_unit_chunks[unit_name][0].ruby_lines_storage
					end # if
				elsif file_status.work_tree == :ignore
					fail 'work_tree == :ignore : ' + file_status.inspect
				elsif unit_name == :non_unit
					puts 'non_unit : ' + file_status.inspect
				else
					assert_path_exist(file_status.file, message)
						test_executable = TestExecutable.new_from_path(file_status.file)
						assert_instance_of(TestExecutable, test_executable)
						testable = test_executable.generatable_unit_file?
						if testable
							test_executable # find unique
						end # if
				end # if
			end.compact # map
    end.flatten # chunk
    assert_instance_of(Array, test_executables)
		assert_include(test_executables.map{|e| e.class}.uniq, TestExecutable) #, test_executables.inspect)
    test_executables.map do |test_executable|
			assert_instance_of(TestExecutable, test_executable)
    end # chunk
    dirty_unit_chunks.each do |test_executable, dirty_files|
    end # each

    Nomination.dirty_test_executables(Repository::This_code_repository).chunk do |test_executable|
					assert_instance_of(TestExecutable, test_executable)
    end # partition
  end # dirty_test_executables
	
		def test_dirty_test_maturities
			[@temp_repo, Repository::This_code_repository].each do |repository|
				Nomination.dirty_test_executables(repository).map do |test_executable|
					assert_instance_of(TestExecutable, test_executable)
					refute_includes(test_executable.methods(false), :to_hash)
					test_executable.class.ancestors.reverse.each do |ancestor|
						refute_includes(ancestor.instance_methods, :to_hash, ancestor.inspect)
					end # each
					refute_includes(test_executable.methods, :to_hash, test_executable.class.ancestors)
					refute_respond_to(test_executable, :to_hash)
					refute_include(NamedCommit::Working_tree.methods(false), :to_hash)
					refute_respond_to(NamedCommit::Working_tree, :to_hash)
					dirty_test_maturity = TestMaturity.new(version: NamedCommit::Working_tree, test_executable: test_executable)
					state = dirty_test_maturity.read_state
					assert_instance_of(Hash, state)
				end # map
			end # each 
			assert_instance_of(Array, Nomination.dirty_test_maturities(@temp_repo))
			dirty_test_maturities = Nomination.dirty_test_maturities(Repository::This_code_repository)
			assert_instance_of(Array, dirty_test_maturities)
			dirty_test_maturities.each do |dirty_test_maturity|
				assert_instance_of(Hash, dirty_test_maturity)
			end # each
		end # dirty_test_maturities
		
  def test_pending
    assert_instance_of(Array, Nomination.pending(Repository::This_code_repository))
    Nomination.pending(Repository::This_code_repository).each do |nomination|
      assert_instance_of(Nomination, nomination)
    end # each
  end # pending

	def test_clean_directory_apply_pending
#!		Nomination.clean_directory_apply_pending(@temp_repo)
	end # clean_directory_apply_pending
	
	def test_apply_pending
#!		Nomination.apply_pending(@temp_repo)
#!		Nomination.apply_pending(Repository::This_code_repository)
	end # apply_pending

	def test_ReferenceObjects
  end # ReferenceObjects



  def test_stage_files
  end # stage_files

	def test_repository
    assert_include(Nomination.instance_methods(false), :repository)
		refute_nil(Nomination::Self.repository, Nomination::Self.inspect)
	end # repository

	def test_unit
	end # unit
	
	def test_test_executable_path
		refute_nil(Nomination::Self.test_executable_path, Nomination::Self.inspect)
		assert_equal(File.expand_path($PROGRAM_NAME), Nomination::Self.test_executable_path)
	end # test_executable_path
	
	def test_test_executable
    assert_include(Nomination.instance_methods(false), :test_executable)
		refute_nil(Nomination::Self.test_executable, Nomination::Self.inspect)
	end # test_executable
	
	def test_files_to_stage
#!		assert_equal([], Nomination::Self.files_to_stage)
	end # files_to_stage
	
  def test_confirm_commit
#!    assert_equal(:echo, @temp_interactive_bottleneck.interactive)
#!    @temp_interactive_bottleneck.confirm_commit
  end # confirm_commit

  def test_validate_commit
    @temp_repo.assert_nothing_to_commit
    @temp_repo.force_change
    #	assert(@temp_repo.something_to_commit?)
    #	@temp_repo.assert_something_to_commit
    #	@temp_repo.validate_commit(:master, [@temp_repo.path+'README'])
#!    @temp_repo.stash!
    @temp_repo.git_command('checkout passed')
#!    @temp_interactive_bottleneck.validate_commit(:stash, [@temp_repo.path + 'README'])
  end # validate_commit

	def test_stage_test_executable
    assert_include(Nomination.instance_methods(false), :stage_test_executable)
#!		refute_nil(Nomination::Self.stage_test_executable, Nomination::Self.inspect)
	end # stage_test_executable

		
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
    assert_equal(NamedCommit::Working_tree, Self.changes_commit, Self.inspect) # nil means working directory (to be stash)
    assert_equal(:unit, Self.test_type, Self.inspect)
    assert_equal(:nomination, Self.unit_name, Self.inspect)
    #		Self.assert_pre_conditions
    #		TestTestExecutable.assert_pre_conditions
  end # assert_pre_conditions

  def test_assert_post_conditions
  end # assert_post_conditions

  def test_Nomination_Examples
  end # Examples
  # rubocop:enable Style/MethodName
end # Nomination
