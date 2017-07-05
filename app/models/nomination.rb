###########################################################################
#    Copyright (C) 2011-2017 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'rom' # how differs from rom-sql
require 'rom-sql' # conflicts with rom-csv and rom-rom
# require 'rom-relation' # conflicts with rom-csv and rom-rom
require 'rom-repository' # conflicts with rom-csv and rom-rom
require 'dry-types'
module Types
  include Dry::Types.module
end # Types

require_relative 'test_executable.rb'
require_relative 'repository.rb'
# !log_timeout require_relative 'interactive_bottleneck.rb'
require_relative 'unit.rb'
# ! require_relative 'unit_maturity.rb'
require_relative '../../app/models/branch.rb'
# !require_relative '../../app/models/test_run.rb'
require_relative '../../app/models/no_db.rb'
require 'virtus'
require 'fileutils'
require_relative '../../app/models/ruby_interpreter.rb'
require_relative '../../app/models/bug.rb'
require_relative '../../app/models/shell_command.rb'
require_relative '../../app/models/branch.rb'
require_relative '../../app/models/ruby_lines_storage.rb'
require_relative '../../app/models/stash.rb'
require_relative '../../app/models/unit_maturity.rb'
# ! require_relative 'editor.rb'

class Nomination < Dry::Types::Value
  module DefinitionalClassMethods # if reference by DefinitionalConstants or not referenced
  end # DefinitionalClassMethods
  extend DefinitionalClassMethods

  module DefinitionalConstants # constant parameters in definition of the type (suggest all CAPS)
  end # DefinitionalConstants
  include DefinitionalConstants

  module DefinitionalClassMethods # if reference DefinitionalConstants
    include DefinitionalConstants
  end # DefinitionalClassMethods
  extend DefinitionalClassMethods

  attribute :changes_commit, NamedCommit # nil means working directory (to be stash)
  attribute :target_branch, Types::Strict::Symbol.default(:edited) # nil means working directory (to be stash)
  attribute :unit_name, Types::Strict::Symbol
  attribute :test_type, Types::Strict::Symbol
	attribute :interactive, Types::Strict::Symbol.default(:interactive) # non-defaults are primarily for non-interactive testing


  module Constructors # such as alternative new methods
    include DefinitionalConstants
		
    def nominate(test_executable)
      Nomination.new(changes_commit: NamedCommit::Working_tree, target_branch: :edited, unit_name: test_executable.unit.model_basename, test_type: test_executable.test_type, interactive: :interactive)
    end # nominate

    def dirty_unit_chunks(repository)
      units = repository.status.group_by do |file_status|
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
    end # dirty_unit_chunks

    def dirty_test_executables(repository)
    dirty_unit_chunks = Nomination.dirty_unit_chunks(repository)
		test_executables = dirty_unit_chunks.keys.map do |unit_name|
      dirty_unit_chunks[unit_name].map do |file_status|
				if file_status.log_file? 
					if dirty_unit_chunks[unit_name].size == 1
					end # if
				elsif file_status.work_tree == :ignore
				elsif unit_name == :non_unit
				else
						test_executable = TestExecutable.new_from_path(file_status.file)
						testable = test_executable.generatable_unit_file?
						if testable
							test_executable # find unique
						end # if
				end # if
			end.compact # map
    end.flatten # chunk
    end # dirty_test_executables

		def dirty_test_maturities(repository)
			Nomination.dirty_test_executables(repository).map do |test_executable|
				dirty_test_maturity = TestMaturity.new(version: NamedCommit::Working_tree, test_executable: test_executable)
				state = dirty_test_maturity.read_state
			end # map
		end # dirty_test_maturities
		
    def pending(repository)
#!			dirty_test_maturities(repository).each do |test_executable|
#!				nominate(test_executable)
#!			end # each
      [Nomination::Self]
    end # pending

	def clean_directory_apply_pending(repository)
		nominations = pending(repository)[0,1] # only one until reliably debugged
		nominations.each(&:apply) # each only one for now
	end # clean_directory_apply_pending
	

	def apply_pending(repository)
		Stash.safely_visit_branch(:edited, repository) {|repository| clean_directory_apply_pending(repository)}
	end # apply_pending
  end # Constructors
  extend Constructors

  module ReferenceObjects # example constant objects of the type (e.g. default_objects)
    include DefinitionalConstants
    TestTestExecutable = Nomination.new(changes_commit: NamedCommit::Working_tree, target_branch: :edited, unit_name: TestExecutable::Examples::TestTestExecutable.unit.model_basename, test_type: TestExecutable::Examples::TestTestExecutable.test_type, interactive: :interactive)
    Self = Nomination.new(changes_commit: NamedCommit::Working_tree, target_branch: :edited, unit_name: RailsishRubyUnit::Executable.model_basename, test_type: :unit, interactive: :interactive)
  end # ReferenceObjects
  include ReferenceObjects

  def stage_files(changes_branch, target_branch, files)
  end # stage_files

	def repository
		@changes_commit.repository # cross repository action not implemented (yet?)
	end # repository

	def unit
		Unit.new(model_basename: @unit_name, project_root_dir: repository.path)
	end # unit
	
	def test_executable_path
		unit.pathname_pattern?(@test_type) # , test = nil)
	end # test_executable_path

	def test_executable
		TestExecutable.new_from_path(test_executable_path, @test_type, repository)
	end # test_executable
	
	def files_to_stage
		unit.tested_symbols(@test_type).map{|file_symbol| unit.pathname_pattern?(file_symbol) }
	end # files_to_stage
	
  def confirm_commit
    if repository.something_to_commit?
      case @interactive
      when :interactive then
        cola_run = repository.git_command('cola')
        cola_run = cola_run.tolerate_status_and_error_pattern(0, /Warning/)
        repository.git_command('rerere')
        cola_run # .assert_post_conditions
        unless repository.something_to_commit?
          #				repository.git_command('cola rebase '+repository.current_branch_name?.to_s)
        end # if
      when :echo then
      when :staged then
        repository.git_command('commit ').assert_post_conditions
      when :all then
        repository.git_command('add . ').assert_post_conditions
        repository.git_command('commit ').assert_post_conditions
      else
        raise 'Unimplemented option @interactive = ' + @interactive.inspect + "\n" + inspect
      end # case
    end # if
    puts 'confirm_commit(' + @interactive.inspect + ' repository.something_to_commit?=' + repository.something_to_commit?.inspect
  end # confirm_commit

  def validate_commit # commit to target_branch
    files_to_stage.each do |p|
      puts p.inspect if $VERBOSE
      repository.git_command(['checkout', @changes_commit.to_s, p])
    end # each
    if repository.something_to_commit?
      confirm_commit
      #		repository.git_command('rebase --autosquash --interactive')
    end # if
  end # validate_commit

	def stage_test_executable
#!		@changes_commit.repository.stage_files(@changes_commit, @target_branch, unit.tested_symbols(@test_type).map{|file_symbol| unit.pathname_pattern?(file_symbol) })
      validate_commit(changes_commit, files_to_stage)
		TestRun.new(test_executable) # recursive_danger!?
	end # stage_test_executable

	def apply
		stage_test_executable(@unit)
	end # apply


  require_relative '../../app/models/assertions.rb'

  module Assertions
    module ClassMethods
      def nested_scope_modules?
        nested_constants = self.class.constants
        message = ''
        assert_includes(included_modules.map(&:name), :Assertions, message)
        assert_equal([:Constants, :Assertions, :ClassMethods], Version.nested_scope_modules?)
      end # nested_scopes

      def assert_nested_scope_submodule(_module_symbol, context = self, message = '')
        message += "\nIn assert_nested_scope_submodule for class #{context.name}, "
        message += "make sure module Constants is nested in #{context.class.name.downcase} #{context.name}"
        message += " but not in #{context.nested_scope_modules?.inspect}"
        assert_includes(constants, :Contants, message)
      end # assert_included_submodule

      def assert_included_submodule(_module_symbol, _context = self, message = '')
        message += "\nIn assert_included_submodule for class #{name}, "
        message += "make sure module Constants is nested in #{self.class.name.downcase} #{name}"
        message += " but not in #{nested_scope_modules?.inspect}"
        assert_includes(included_modules, :Contants, message)
      end # assert_included_submodule

      def assert_nested_and_included(module_symbol, _context = self, _message = '')
        assert_nested_scope_submodule(module_symbol)
        assert_included_submodule(module_symbol)
      end # assert_nested_and_included

      def assert_pre_conditions(message = '')
        message += "In assert_pre_conditions, self=#{inspect}"
        #	assert_nested_and_included(:ClassMethods, self)
        #	assert_nested_and_included(:Constants, self)
        #	assert_nested_and_included(:Assertions, self)
				assert_respond_to(Nomination, :nominate, Nomination.methods(false))
				assert_include(Nomination.methods, :nominate)
				assert_respond_to(Nomination::Self, :changes_commit, Nomination.instance_methods(false))
				assert_include(Nomination.instance_methods(false), :changes_commit)
				refute_nil(Nomination::Self.changes_commit.repository, Nomination::Self.inspect)
        self
      end # assert_pre_conditions

      def assert_post_conditions(message = '')
        message += "In assert_post_conditions, self=#{inspect}"
        self
      end # assert_post_conditions
     end # ClassMethods

    def assert_pre_conditions(message = '')
      message += "In assert_pre_conditions, self=#{inspect}"
      assert_instance_of(Symbol, @changes_commit)
      assert_instance_of(Symbol, @unit_name)
      assert_instance_of(Symbol, @test_type)
      self # return for command chaining
    end # assert_pre_conditions

    def assert_post_conditions(message = '')
      message += "In assert_post_conditions, self=#{inspect}"
      self # return for command chaining
    end # assert_post_conditions
  end # Assertions
  include Assertions
  extend Assertions::ClassMethods
end # Nomination
