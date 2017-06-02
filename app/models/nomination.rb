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

  attribute :commit, NamedCommit # nil means working directory (to be stash)
  attribute :target_branch, Types::Strict::Symbol.default(:edited) # nil means working directory (to be stash)
  attribute :unit, Types::Strict::Symbol
  attribute :test_type, Types::Strict::Symbol

  module Constructors # such as alternative new methods
    include DefinitionalConstants
    def nominate(test_executable)
      Nomination.new(commit: NamedCommit::Working_tree, target_branch: :edited, unit: test_executable.unit.model_basename, test_type: test_executable.test_type)
    end # nominate

    def pending
      [Nomination::Self]
    end # pending

    def dirty_test_executable
      @commit.repository.status.map do |file_status|
        if file_status.log_file?
          nil
        elsif file_status.work_tree == :ignore
          nil
        else
          lookup = FilePattern.find_from_path(file_status.file)
          unless lookup.nil?
            test_executable = TestExecutable.new_from_path(file_status.file)
            testable = test_executable.generatable_unit_file?
            if testable
              test_executable # find unique
            end # if
          end # if
        end # if
      end.select { |t| !t.nil? }.uniq # map
    end # dirty_test_executable

    def clean_apply
      pending.each(&:apply) # each
    end # clean_apply

    def apply
      if test_executable.repository.something_to_commit?
        test_executable.repository.stash!
        clean_apply
        test_executable.repository.pop
      else
        clean_apply
      end # if
    end # apply
  end # Constructors

  extend Constructors

  module ReferenceObjects # example constant objects of the type (e.g. default_objects)
    include DefinitionalConstants
    TestTestExecutable = Nomination.new(commit: NamedCommit::Working_tree, target_branch: :edited, unit: TestExecutable::Examples::TestTestExecutable.unit.model_basename, test_type: TestExecutable::Examples::TestTestExecutable.test_type)
    Self = Nomination.new(commit: NamedCommit::Working_tree, target_branch: :edited, unit: RailsishRubyUnit::Executable.model_basename, test_type: :unit)
  end # ReferenceObjects
  include ReferenceObjects

  def apply
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

      def asset_nested_and_included(module_symbol, _context = self, _message = '')
        assert_nested_scope_submodule(module_symbol)
        assert_included_submodule(module_symbol)
      end # asset_nested_and_included

      def assert_pre_conditions(message = '')
        message += "In assert_pre_conditions, self=#{inspect}"
        #	asset_nested_and_included(:ClassMethods, self)
        #	asset_nested_and_included(:Constants, self)
        #	asset_nested_and_included(:Assertions, self)
        self
      end # assert_pre_conditions

      def assert_post_conditions(message = '')
        message += "In assert_post_conditions, self=#{inspect}"
        self
      end # assert_post_conditions
     end # ClassMethods

    def assert_pre_conditions(message = '')
      message += "In assert_pre_conditions, self=#{inspect}"
      assert_instance_of(Symbol, @commit)
      assert_instance_of(Symbol, @unit)
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
  # self.assert_pre_conditions
end # Nomination
