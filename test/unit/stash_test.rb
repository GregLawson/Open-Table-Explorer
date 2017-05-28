###########################################################################
#    Copyright (C) 2017 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative '../../app/models/stash.rb'
class Minimal2Test < TestCase
  include RailsishRubyUnit::Executable.model_class?::DefinitionalConstants
  include RailsishRubyUnit::Executable.model_class?::ReferenceObjects
	include ReflogRegexp
  module Examples
  end #  Examples
  include Examples

  # rubocop:disable Style/MethodName

	def setup
    @temp_repo = Repository.create_test_repository
  end # setup

  def teardown
    Repository.delete_even_nonxisting(@temp_repo.path)
#    assert_empty(Dir[Cleanup_failed_test_paths], Cleanup_failed_test_paths)
  end # teardown

	def test_wip!
		@temp_repo.force_change
		Stash.wip!(@temp_repo)
    assert_equal([:clean], @temp_repo.state?)
	end # wip!
		
	def test_pop!
		@temp_repo.force_change
		Stash.wip!(@temp_repo)
    assert_equal([:clean], @temp_repo.state?)
		Stash.pop!(@temp_repo)
    refute_equal([:clean], @temp_repo.state?)
	end # pop!
	
	def test_list
		wip_example = "stash@{0}: WIP on testing: 0eeec72 Merge branch 'passed' into testing"
		command_string = 'show stash'
		cached_run = Repository::This_code_repository.git_command(command_string)
    regexp = /stash@{0}: WIP on / * Name_regexp.capture(:parent_branch) * /: / *
             SHA1_hex_short.capture(:sha7) * / Merge branch '/ * Name_regexp.capture(:merge_from) * /' into / * Name_regexp.capture(:merge_into)
#		assert_match(regexp, cached_run.output, cached_run.inspect)
#		assert_include([Master_branch, Passed_branch, Tested_branch, Edited_branch], BranchReference.list(Repository::This_code_repository),cached_run.inspect)
	end # list

	
  def test_Stash_DefinitionalConstants
  end # DefinitionalConstants





	
  def test_stash_and_checkout
    @temp_repo.force_change
  end # stash_and_checkout

	def test_included_module_names
		this_class = RailsishRubyUnit::Executable.model_class?
#!		assert_includes(this_class.included_module_names, (this_class.name + '::DefinitionalClassMethods').to_sym)
		assert_includes(this_class.included_module_names, (this_class.name + '::DefinitionalConstants').to_sym)
#!		assert_includes(this_class.included_module_names, (this_class.name + '::Constructors').to_sym)
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
					if trial_eval.kind_of?(Module)
						trial_eval
					else
						nil
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
#!		assert_equal(this_class::ClassInterface, Dry::Types::Struct::ClassInterface)
#!		refute_includes(this_class.nested_scope_modules, Dry::Types::Struct::ClassInterface)
	end # nested_scope_modules
			
	def test_nested_scope_module_names
		this_class = RailsishRubyUnit::Executable.model_class?
		assert_includes(this_class.nested_scope_module_names, (this_class.name + '::DefinitionalClassMethods').to_sym)
		assert_includes(this_class.nested_scope_module_names, (this_class.name + '::DefinitionalConstants').to_sym)
		assert_includes(this_class.nested_scope_module_names, (this_class.name + '::Constructors').to_sym)
		assert_includes(this_class.nested_scope_module_names, (this_class.name + '::ReferenceObjects').to_sym)
		assert_includes(this_class.nested_scope_module_names, (this_class.name + '::Assertions').to_sym)
		assert_includes(this_class.constants, :Stash_object)
	end # nested_scope_module_names
			
			def test_assert_nested_scope_submodule
				this_class = RailsishRubyUnit::Executable.model_class?
				this_class.assert_nested_scope_submodule((this_class.name + '::DefinitionalClassMethods').to_sym)
				this_class.assert_nested_scope_submodule((this_class.name + '::DefinitionalConstants').to_sym)
				this_class.assert_nested_scope_submodule((this_class.name + '::Constructors').to_sym)
				this_class.assert_nested_scope_submodule((this_class.name + '::ReferenceObjects').to_sym)
				this_class.assert_nested_scope_submodule((this_class.name + '::Assertions').to_sym)
			end # assert_included_submodule
			
			def test_assert_included_submodule
				this_class = RailsishRubyUnit::Executable.model_class?
#!class				this_class.assert_included_submodule((this_class.name + '::DefinitionalClassMethods').to_sym)
				this_class.assert_included_submodule((this_class.name + '::DefinitionalConstants').to_sym)
#!class				this_class.assert_included_submodule((this_class.name + '::Constructors').to_sym)
				this_class.assert_included_submodule((this_class.name + '::ReferenceObjects').to_sym)
				this_class.assert_included_submodule((this_class.name + '::Assertions').to_sym)
			end # assert_included_submodule
			
			def test_asset_nested_and_included
				this_class = RailsishRubyUnit::Executable.model_class?
#!class				this_class.asset_nested_and_included((this_class.name + '::DefinitionalClassMethods').to_sym)
				this_class.asset_nested_and_included((this_class.name + '::DefinitionalConstants').to_sym)
#!class				this_class.asset_nested_and_included((this_class.name + '::Constructors').to_sym)
				this_class.asset_nested_and_included((this_class.name + '::ReferenceObjects').to_sym)
				this_class.asset_nested_and_included((this_class.name + '::Assertions').to_sym)
			end # asset_nested_and_included
			
  def test_Stash_assert_pre_conditions
		this_class = RailsishRubyUnit::Executable.model_class?
		this_class.assert_pre_conditions
		message = ''
		my_style_modules = [this_class::Assertions, this_class::ReferenceObjects, this_class::DefinitionalConstants]
		my_style_module_names = my_style_modules.map{|m| m.name.to_sym}
		assert_includes(my_style_module_names, (this_class.name + '::ReferenceObjects').to_sym, message)
		assert_includes(my_style_module_names, (this_class.name + '::DefinitionalConstants').to_sym, message)
		assert_includes(my_style_module_names, (this_class.name + '::Assertions').to_sym, message)

		super_class = this_class.superclass
		superclass_modules = super_class.included_modules
		superclass_module_names = super_class.included_modules.map(&:module_name)
		message = ''
#		assert_includes(super_class.included_modules.map(&:module_name), :'Dry::Equalizer::Methods', message)
		assert_includes(super_class.included_modules.map(&:module_name), :'JSON::Ext::Generator::GeneratorMethods::Object', message)
#! ruby 2.4		assert_includes(Module.used_modules.map(&:module_name), :'JSON::Ext::Generator::GeneratorMethods::Object', message)
  end # assert_pre_conditions

  def test_Stash_assert_post_conditions
		RailsishRubyUnit::Executable.model_class?.assert_pre_conditions
  end # assert_post_conditions

  def test_assert_pre_conditions
		Stash_object.assert_pre_conditions
  end # assert_pre_conditions

  def test_assert_post_conditions
		Stash_object.assert_post_conditions
  end # assert_post_conditions

  # rubocop:enable Style/MethodName
end # Stash
