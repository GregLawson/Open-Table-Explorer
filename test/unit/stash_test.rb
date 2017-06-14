###########################################################################
#    Copyright (C) 2017 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative '../../app/models/stash.rb'
class StashTest < TestCase
  include RailsishRubyUnit::Executable.model_class?::DefinitionalConstants
  include RailsishRubyUnit::Executable.model_class?::ReferenceObjects
  include ReflogRegexp
  module Examples
    Wip_example = "stash@{0}: WIP on testing: 0eeec72 Merge branch 'passed' into testing".freeze
		Temp_repo_example = 'Saved working directory and index state WIP on master: bef99b3 create_empty initial commit of README\nHEAD is now at bef99b3 create_empty initial commit of README\n'
    Stash_object = Stash.new(initialization_string: :stash, repository: Repository::This_code_repository,
			annotation: Wip_example)
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

  def test_pop!
    @temp_repo.force_change
    Stash.wip!(@temp_repo)
    assert_equal([:clean], @temp_repo.state?)
    Stash.pop!(@temp_repo)
    refute_equal([:clean], @temp_repo.state?)
  end # pop!

	def test_Stash_DefinitionalConstants
		capture = MatchCapture.new(string: Wip_example, regexp: List_regexp_array)
		assert_match(/stash@\{0\}: WIP on /, Wip_example)
		assert_match(List_regexp_array[0], Wip_example)
		
#!    capture.assert_refinement(:left)
    capture.assert_refinement(:exact)
		refinement = capture.priority_refinements
    Stash.assert_refine(Wip_example, List_regexp_array)
  end # DefinitionalConstants


  def test_wip!
    @temp_repo.force_change
    command_string = 'stash save --include-untracked'
    cached_run = @temp_repo.git_command(command_string)
		cached_run.assert_post_conditions
  end # wip!

	def test_state
    capture = MatchCapture.new(string: Stash_object.annotation, regexp: List_regexp_array)
		refinement = capture.priority_refinements
		message = capture.inspect + "\n" + refinement.inspect
		assert_match(/[[:print:]]{10,200}/, "\ create_empty\ initial\ commit\ of\ README\nHEAD\ is\ now\ at\ 46a2b13\ create_empty\ initial\ commit\ of\ README\n", message)
		assert_match(/\A[[:print:]\n]{10,400}\Z/, "\ create_empty\ initial\ commit\ of\ README\nHEAD\ is\ now\ at\ 46a2b13\ create_empty\ initial\ commit\ of\ README\n", message)
		assert(capture.success?, message)
#!		assert_equal([], refinement, message)
#!    capture.assert_refinement(:left)
    capture.assert_refinement(:exact, message)
    ret = Stash.wip!(@temp_repo)
    assert_equal([:clean], @temp_repo.state?)
    assert_instance_of(Stash, ret)
#!		assert_equal({}, capture.to_hash, ret.inspect)
		end # state
		
  def test_list
    command_string = 'show list'
    run = Repository::This_code_repository.git_command(command_string)
    Stash.refine(run.output, List_regexp_array, MatchCapture)
    refinements = Stash.list(Repository::This_code_repository)
    assert_instance_of(MatchRefinement, refinements)
    #		assert_match(regexp, cached_run.output, cached_run.inspect)
    #		assert_include([Master_branch, Passed_branch, Tested_branch, Edited_branch], BranchReference.list(Repository::This_code_repository),cached_run.inspect)
  end # list

  def test_confirm_branch_switch
    assert_equal(:master, Branch.current_branch_name?(@temp_repo))
    @temp_repo.force_change
		branch = :passed
		repository = @temp_repo
    checkout_branch = repository.git_command("checkout #{branch}")
    if checkout_branch.errors == "Already on '#{branch}'\n" && checkout_branch.errors != "Switched to branch '#{branch}'\n"
      checkout_branch #.assert_post_conditions
		elsif checkout_branch.errors == "Switched to branch '#{branch}'\n"
      checkout_branch #.assert_post_conditions
		else
			checkout_branch.assert_post_conditions
    end # if
#!		checkout_branch.assert_post_conditions
    Stash.confirm_branch_switch(:passed, @temp_repo)
    assert_equal(:passed, Branch.current_branch_name?(@temp_repo))
    Stash.confirm_branch_switch(:master, @temp_repo)
    assert_equal(:master, Branch.current_branch_name?(@temp_repo))
  end # confirm_branch_switch

  def test_safely_visit_branch
		repository =  @temp_repo
    start_branch = Branch.current_branch_name?(repository)
		assert_equal(:master, start_branch)
		target_branch = :master # no movement yet
		refute(start_branch != target_branch)
    @temp_repo.force_change
		need_stash = repository.something_to_commit? && start_branch != target_branch
		assert(repository.something_to_commit?)
    target_branch = :passed
    assert_equal(start_branch, Stash.safely_visit_branch(repository, start_branch) { start_branch })
    assert_equal(start_branch, Stash.safely_visit_branch(repository, start_branch) { Branch.current_branch_name?(@temp_repo) })
    target_branch = :master
    checkout_target = @temp_repo.git_command("checkout #{target_branch}")
    #		assert_equal("Switched to branch '#{target_branch}'\n", checkout_target.errors)
    target_branch = :passed
#!    assert_equal(target_branch, Stash.safely_visit_branch(repository, target_branch) { Branch.current_branch_name?(@temp_repo) })
    Stash.safely_visit_branch(repository, target_branch) do
      Branch.current_branch_name?(@temp_repo)
    end #
  end # safely_visit_branch

  def test_stash_and_checkout
    @temp_repo.force_change
		Stash.stash_and_checkout(:passed, @temp_repo)
#!		assert_equal(:passed, Branch.current_branch_name?(@temp_repo))
  end # stash_and_checkout

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
    # !		assert_equal(this_class::ClassInterface, Dry::Types::Struct::ClassInterface)
    # !		refute_includes(this_class.nested_scope_modules, Dry::Types::Struct::ClassInterface)
  end # nested_scope_modules

  def test_nested_scope_module_names
    this_class = RailsishRubyUnit::Executable.model_class?
    assert_includes(this_class.nested_scope_module_names, (this_class.name + '::DefinitionalClassMethods').to_sym)
    assert_includes(this_class.nested_scope_module_names, (this_class.name + '::DefinitionalConstants').to_sym)
    assert_includes(this_class.nested_scope_module_names, (this_class.name + '::Constructors').to_sym)
    assert_includes(this_class.nested_scope_module_names, (this_class.name + '::ReferenceObjects').to_sym)
    assert_includes(this_class.nested_scope_module_names, (this_class.name + '::Assertions').to_sym)
#!    assert_includes(this_class.constants, :Stash_object)
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
    # !class				this_class.assert_included_submodule((this_class.name + '::DefinitionalClassMethods').to_sym)
    this_class.assert_included_submodule((this_class.name + '::DefinitionalConstants').to_sym)
    # !class				this_class.assert_included_submodule((this_class.name + '::Constructors').to_sym)
    this_class.assert_included_submodule((this_class.name + '::ReferenceObjects').to_sym)
    this_class.assert_included_submodule((this_class.name + '::Assertions').to_sym)
    end # assert_included_submodule

  def test_assert_nested_and_included
    this_class = RailsishRubyUnit::Executable.model_class?
    # !class				this_class.assert_nested_and_included((this_class.name + '::DefinitionalClassMethods').to_sym)
    this_class.assert_nested_and_included((this_class.name + '::DefinitionalConstants').to_sym)
    # !class				this_class.assert_nested_and_included((this_class.name + '::Constructors').to_sym)
    this_class.assert_nested_and_included((this_class.name + '::ReferenceObjects').to_sym)
    this_class.assert_nested_and_included((this_class.name + '::Assertions').to_sym)
    end # assert_nested_and_included

  def test_Stash_assert_pre_conditions
    this_class = RailsishRubyUnit::Executable.model_class?
    this_class.assert_pre_conditions
    message = ''
    my_style_modules = [this_class::Assertions, this_class::ReferenceObjects, this_class::DefinitionalConstants]
    my_style_module_names = my_style_modules.map { |m| m.name.to_sym }
    assert_includes(my_style_module_names, (this_class.name + '::ReferenceObjects').to_sym, message)
    assert_includes(my_style_module_names, (this_class.name + '::DefinitionalConstants').to_sym, message)
    assert_includes(my_style_module_names, (this_class.name + '::Assertions').to_sym, message)

    super_class = this_class.superclass
    superclass_modules = super_class.included_modules
    superclass_module_names = super_class.included_modules.map(&:module_name)
    message = ''
    #		assert_includes(super_class.included_modules.map(&:module_name), :'Dry::Equalizer::Methods', message)
    assert_includes(super_class.included_modules.map(&:module_name), :'JSON::Ext::Generator::GeneratorMethods::Object', message)
    # ! ruby 2.4		assert_includes(Module.used_modules.map(&:module_name), :'JSON::Ext::Generator::GeneratorMethods::Object', message)
  end # assert_pre_conditions

  def test_Stash_assert_post_conditions
    RailsishRubyUnit::Executable.model_class?.assert_pre_conditions
  end # assert_post_conditions
	
	def test_assert_refine
		acquisition_string = 'cat'
		regexp =  [/c/, /a/, /t/]
		capture_class = MatchCapture
		capture = capture_class.new(string: acquisition_string, regexp: regexp)
		capture.assert_refinement(:exact)
		refinement = capture.priority_refinements
#!		assert_refine(acquisition_string, regexp)
	end # refine
			
	def test_assert_safely_visit_branch
#!		Stash.assert_safely_visit_branch(@temp_repo, Branch.current_branch_name?(@temp_repo))
		Stash.assert_safely_visit_branch(@temp_repo, Branch.current_branch_name?(@temp_repo)){|repository, target_branch| repository.force_change}
		Stash.assert_safely_visit_branch(@temp_repo, :passed){|repository| repository.force_change}
	end # assert_safely_visit_branch

  def test_assert_pre_conditions
    Stash_object.assert_pre_conditions
  end # assert_pre_conditions

  def test_assert_post_conditions
    Stash_object.assert_post_conditions
  end # assert_post_conditions

  # rubocop:enable Style/MethodName
end # Stash
