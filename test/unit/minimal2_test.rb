###########################################################################
#    Copyright (C) 2012-2017 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative '../../app/models/minimal2.rb'
require_relative '../../app/models/unit.rb'
class Minimal2Test < TestCase
  include RailsishRubyUnit::Executable.model_class?::DefinitionalConstants
  include RailsishRubyUnit::Executable.model_class?::ReferenceObjects
  module Examples
  end #  Examples
  include Examples

  def setup
    # !    @temp_repo = Repository.create_test_repository
  end # setup

  def teardown
    # !    Repository.delete_even_nonxisting(@temp_repo.path)
    #    assert_empty(Dir[Cleanup_failed_test_paths], Cleanup_failed_test_paths)
  end # teardown

  # rubocop:disable Style/MethodName
  def test_Minimal_DefinitionalConstants
  end # DefinitionalConstants

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

  def test_nested_scope_module_names
    this_class = RailsishRubyUnit::Executable.model_class?
    assert_includes(this_class.nested_scope_module_names, (this_class.name + '::DefinitionalClassMethods').to_sym)
    assert_includes(this_class.nested_scope_module_names, (this_class.name + '::DefinitionalConstants').to_sym)
    assert_includes(this_class.nested_scope_module_names, (this_class.name + '::Constructors').to_sym)
    assert_includes(this_class.nested_scope_module_names, (this_class.name + '::ReferenceObjects').to_sym)
    assert_includes(this_class.nested_scope_module_names, (this_class.name + '::Assertions').to_sym)
    assert_includes(this_class.constants, :Minimal_object)
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

  def test_Minimal_assert_pre_conditions
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
    assert_includes(super_class.included_modules.map(&:module_name), :'Dry::Equalizer::Methods', message)
    assert_includes(super_class.included_modules.map(&:module_name), :'JSON::Ext::Generator::GeneratorMethods::Object', message)
    # ! ruby 2.4		assert_includes(Module.used_modules.map(&:module_name), :'JSON::Ext::Generator::GeneratorMethods::Object', message)
  end # assert_pre_conditions

  def test_Minimal_assert_post_conditions
    RailsishRubyUnit::Executable.model_class?.assert_pre_conditions
  end # assert_post_conditions

  def test_assert_pre_conditions
    Minimal_object.assert_pre_conditions
  end # assert_pre_conditions

  def test_assert_post_conditions
    Minimal_object.assert_post_conditions
  end # assert_post_conditions

  def test_Minimal_Examples
  end # Examples
  # rubocop:enable Style/MethodName
end # Minimal
