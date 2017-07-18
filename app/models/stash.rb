###########################################################################
#    Copyright (C) 2017 by Greg Lawson
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
require_relative 'repository.rb'
require_relative 'branch.rb'
require_relative 'acquisition.rb'
module Types
  include Dry::Types.module
end # Types

class Stash < NamedCommit
  module DefinitionalClassMethods # if reference by DefinitionalConstants or not referenced

		def refine(acquisition_string, regexp, capture_class = MatchCapture, &block)
			capture = capture_class.new(string: acquisition_string, regexp: regexp)
			refinement = capture.priority_refinements
		end # refine

    def pop!(repository, pop = :apply)
      apply_run = repository.git_command('stash ' + pop.to_s + ' --quiet')
      if apply_run.errors =~ /Could not restore untracked files from stash/
        puts apply_run.errors
        puts repository.git_command('status').output
        puts repository.git_command('stash show').output
      else
        apply_run # .assert_post_conditions('unexpected stash apply fail')
      end # if
#!      merge_cleanup
    end # pop!

  end # DefinitionalClassMethods
  extend DefinitionalClassMethods

  module DefinitionalConstants # constant parameters in definition of the type (suggest all CAPS)
    include ReflogRegexp
		Title_regexp = (/Saved working directory and index state/ | /stash@\{0\}:/).capture(:title)
		Merge_precommit_regexp = / Merge branch '/ * Name_regexp.capture(:merge_from) * /' into / * Name_regexp.capture(:merge_into)
		Stash_precommit_regexp = / / * (Merge_precommit_regexp | /[[:print:]\n]*\Z/).capture(:precommit)
    List_regexp_array = [Title_regexp, / WIP on /, Name_regexp.capture(:parent_branch), /: /,
                         SHA1_hex_short, Stash_precommit_regexp].freeze
    List_regexp = Regexp[List_regexp_array]
  end # DefinitionalConstants
  include DefinitionalConstants

  module DefinitionalClassMethods # if reference DefinitionalConstants
    include DefinitionalConstants
  end # DefinitionalClassMethods
  extend DefinitionalClassMethods

  attribute :annotation, Types::Strict::String
#!  attribute :from_branch, Types::Strict::Symbol
  #    attribute :name, Types::Strict::Symbol | Types::Strict::String
  #		attribute :data_regexp, Types::Coercible::String
  #		attribute :ruby_conversion, Types::Strict::String.optional

  module Constructors # such as alternative new methods
    include DefinitionalConstants
    def wip!(repository)
      command_string = 'stash save --include-untracked'
      run = repository.git_command(command_string) #.assert_post_conditions
      refine(run.output, List_regexp_array, MatchCapture)
			Stash.new(initialization_string: :stash, repository: Repository::This_code_repository, annotation: run.output)
    end # wip!

		def state
			capture = MatchCapture.new(string: @annotation, regexp: List_regexp_array)
			refinement = capture.priority_refinements
			message = capture.inspect + "\n" + refinement.inspect
		end # state
		
    def list(repository)
      command_string = 'stash list'
      run = repository.git_command(command_string)
      refine(run.output, List_regexp_array, MatchCapture)
		end # list

  def confirm_branch_switch(branch, repository)
    checkout_branch = repository.git_command("checkout #{branch}")
    if checkout_branch.errors == "Already on '#{branch}'\n" && checkout_branch.errors != "Switched to branch '#{branch}'\n"
      checkout_branch #.assert_post_conditions
		elsif checkout_branch.errors == "Switched to branch '#{branch}'\n"
      checkout_branch #.assert_post_conditions
		else
			checkout_branch.assert_post_conditions
    end # if
    checkout_branch # for command chaining
  end # confirm_branch_switch

  def need_stash(repository, target_branch)
		repository.something_to_commit? && start_branch != target_branch
	end # need_stash
	
	# This is safe in the sense that a stash saves all files
  # and a stash apply restores all tracked files
  # safe is meant to mean no files or changes are lost or buried.
	def safely_visit_branch(repository, target_branch, &block)
    start_branch = Branch.current_branch_name?(repository)
		if repository.something_to_commit?
			Stash.stash_and_checkout(target_branch, repository)
      ret = yield(:stash)
      confirm_branch_switch(start_branch, repository)
			Stash.pop!(repository)
		elsif start_branch != target_branch
      confirm_branch_switch(target_branch, repository)
      ret = yield(start_branch)
      confirm_branch_switch(start_branch, repository)
		else
      ret = yield(start_branch)
		end # if
    ret
	rescue Exception => exception_raised
			unless repository.something_to_commit?
				confirm_branch_switch(start_branch, repository)
				Stash.pop!(repository)
			else
				raise exception_raised
			end # unless
  end # safely_visit_branch

  def stash_and_checkout(target_branch, repository)
    start_branch = Branch.current_branch_name?(repository)
    commit_with_changes = start_branch #
    push = repository.something_to_commit? # remember
    if push
      Stash.wip!(repository)
#!      merge_cleanup
      commit_with_changes = :stash
    end # if

    if start_branch != target_branch
#!      confirm_branch_switch(target_branch)
    end # if
    push # if switched?
  end # stash_and_checkout
  end # Constructors
  extend Constructors

  module ReferenceObjects # example constant objects of the type (e.g. default_objects)
    include DefinitionalConstants
  end # ReferenceObjects
  include ReferenceObjects

  require_relative '../../app/models/assertions.rb'

  module Assertions
    module ClassMethods
      def assert_nested_scope_submodule(module_symbol, context = self, message = '')
        message += "\nIn assert_nested_scope_submodule for class #{context.name}, "
        message += "make sure module Constants is nested in #{context.class.name.downcase} #{context.name}"
        message += " but not in #{context.nested_scope_module_names}"
        assert_includes(nested_scope_module_names, module_symbol)
      end # assert_included_submodule

      def assert_included_submodule(module_symbol, _context = self, message = '')
        message += "\nIn assert_included_submodule for class #{name}, "
        message += "make sure module Constants is nested in #{self.class.name.downcase} #{name}"
        message += " but not in #{nested_scope_module_names}"
        assert_includes(included_modules.map(&:module_name), module_symbol)
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
        self
      end # assert_pre_conditions

      def assert_post_conditions(message = '')
        message += "In assert_post_conditions, self=#{inspect}"
        self
      end # assert_post_conditions
			
			def assert_refine(acquisition_parameters, regexp, capture_class = MatchCapture)
				capture = capture_class.new(string: acquisition_parameters, regexp: regexp)
				capture.assert_refinement(:exact)
				refinement = capture.priority_refinements
			end # refine
			
			def assert_safely_visit_branch(repository, target_branch, &block)
				start_state = repository.status
				safely_visit_branch(repository, target_branch, &block)
				assert_equal(start_state, repository.status)
			end # assert_safely_visit_branch

     end # ClassMethods

    def assert_pre_conditions(message = '')
      message += "In assert_pre_conditions, self=#{inspect}"
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
end # Stash
