###########################################################################
#    Copyright (C) 2011-2017 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../../app/models/test_environment_test_unit.rb'
# require_relative 'test_environment'
require_relative '../../app/models/cache.rb'
require_relative '../../app/models/unit.rb'
require_relative '../assertions/ruby_assertions_test_unit.rb'
require 'benchmark'

class TestClass
  include Cache
  extend Cache::ClassMethods
  extend Cache::Assertions::ClassMethods
  def make_instance_variables
		cache do
			2
		end # cache
  end # make_instance_variables
	
	def self.make_class_cache
		cache(:make_class_cache) do
			'class cache value'
		end # cache
	end # make_class_cache
end # TestClass

class CacheClassTest < TestCase
  include RubyAssertions

	def setup
		TestClass.clear_cache(:make_class_cache)
  end # setup

  def teardown
  end # teardown

  def test_cache_const_name
    assert_equal(:Cached_make_class_cache, TestClass.cache_const_name(:make_class_cache))
  end # cache_const_name

  def test_cache
    TestClass.refute_cached(:test, TestClass.constants.inspect)
    TestClass.refute_cached(:cache, TestClass.constants.inspect)
    TestClass.refute_cached(:test, TestClass.constants.inspect)
		cache_name = :make_class_cache
    TestClass.refute_cached(cache_name, TestClass.constants.inspect)
		TestClass.const_set(TestClass.cache_const_name(cache_name), 'test_cached')
    TestClass.assert_cached(cache_name, TestClass.constants.inspect)
    TestClass.refute_cached(:cache, TestClass.constants.inspect)
		
		TestClass.clear_cache(cache_name)
    TestClass.refute_cached(cache_name, TestClass.constants.inspect)
    TestClass.refute_cached(:cache, TestClass.constants.inspect)
    TestClass.refute_cached(:test, TestClass.constants.inspect)
		
    TestClass.make_class_cache
    TestClass.refute_cached(:test, TestClass.constants.inspect)
		TestClass.clear_cache(:cache)
    TestClass.refute_cached(:cache, TestClass.constants.inspect)
    TestClass.assert_cached(:make_class_cache, TestClass.constants.inspect)
  end # cache

  def test_explain_cache
    object = TestClass
    cache_name = :make_class_cache
    TestClass.refute_cached(:cache, TestClass.constants.inspect)
    TestClass.refute_cached(:test, TestClass.constants.inspect)
    TestClass.refute_cached(cache_name, TestClass.constants.inspect)
#!		assert_equal([:ClassMethods, :Assertions], TestClass.constants)
#!    assert_equal(':make_class_cache is not cached as constant TestClass::Cached_make_class_cache in []', object.explain_cache(cache_name))
    TestClass.make_class_cache
    assert_equal(':make_class_cache is cached as constant TestClass::Cached_make_class_cache = "class cache value"', object.explain_cache(cache_name))
  end # explain_cache

  def test_clear_cache
  end # clear_cache

	def test_timing

		Unit.refute_cached(:all_basenames)
		cache_miss = Benchmark.measure { Unit.all_basenames }
		message = 'cache_miss = ' + cache_miss.inspect
		Unit.assert_cached(:all_basenames, message)
		cache_hit = Benchmark.measure { Unit.all_basenames }
		message += ', cache_hit = ' + cache_hit.inspect
		assert_operator(cache_miss.real, :>, Benchmark.measure { Unit::Cached_all_basenames }.real, message)
		assert_operator(cache_miss.real, :>, cache_hit.real, message)
		message += "\n" + 'all_basenames = ' + Benchmark.measure { Unit.all_basenames }.inspect
		message += "\n" + 'all = ' + Benchmark.measure { Unit.all }.inspect
		puts message
	end # 
	
  def test_assert_cached
    TestClass.refute_cached(:cache, TestClass.constants.inspect)
    TestClass.make_class_cache
    TestClass.refute_cached(:cache, TestClass.constants.inspect)
    TestClass.assert_cached(:make_class_cache, TestClass.constants.inspect)
  end # assert_cached

  def test_refute_cached
    TestClass.refute_cached(:cache)
    TestClass.refute_cached(:make_class_cache)
  end # refute_cached
end # Cache

class CacheTest < TestCase
  include RubyAssertions

  def test_cache_const_name
    assert_equal(:@cached_test, TestClass.new.cache_const_name(:test))
  end # cache_const_name

  def test_cached?
    object = TestClass.new
    cache_name = :test
    refute(object.cached?(cache_name), object.explain_cache(cache_name))
    assert_equal(2, object.cache(cache_name) { || 2 })
    assert(object.cached?(cache_name), object.explain_cache(cache_name))
		
		
  end # cached?

  def test_cache
    TestClass.refute_cached(:test, TestClass.constants.inspect)
    object = TestClass.new
    #		object = CA_current_year
    # !		object = object.clone
    cache_name = :test
    assert_raise(RuntimeError) { object.cache(:test) }
    # !		block =
    cache_const_name = ('Cached_' + cache_name.to_s).to_sym
    assert_equal(:Cached_test, cache_const_name)
    refute(object.class.const_defined?(cache_const_name))
    TestClass.refute_cached(:test, TestClass.constants.inspect)
    ret = 2
    refute(object.class.const_defined?(cache_const_name))
    refute_nil(object.cache(:test) { || 2 }, object.inspect)
    assert_equal(2, object.cache(:test) { || 2 })
    assert_equal(2, object.cache(:test) { || 3 })
    assert_equal(2, object.cache { || 2 })

  end # cache

  def test_explain_cache
    object = TestClass.new
    cache_name = :test
    assert_equal(':test is not cached as instance variable :@cached_test in []', object.explain_cache(cache_name))
    assert_equal(2, object.cache(cache_name) { || 2 })
    assert_equal(':test is cached as instance variable :@cached_test = 2', object.explain_cache(cache_name))
    assert_equal(':junk is not cached as instance variable :@cached_junk in [:@cached_test]', object.explain_cache(:junk))
  end # explain_cache

  def test_clear_cache
  end # clear_cache

  def test_assert_cached
    object = TestClass.new
    cache_name = :test
    assert_equal(2, object.cache(cache_name) { || 2 })
    object.assert_cached(cache_name)
  end # assert_cached

  def test_refute_cached
    object = TestClass.new
    cache_name = :test
    object.refute_cached(cache_name)
  end # refute_cached

	def test_included_module_names
		this_class = TestClass
#		assert_includes(this_class.included_module_names, (this_class.name + '::ClassMethods').to_sym)
#		assert_includes(this_class.included_module_names, (this_class.name + '::DefinitionalConstants').to_sym)
#		assert_includes(this_class.included_module_names, (this_class.name + '::Constructors').to_sym)
#		assert_includes(this_class.included_module_names, (this_class.name + '::ReferenceObjects').to_sym)
#!		assert_includes(this_class.included_module_names, (this_class.name + '::Assertions').to_sym)
	end # included_module_names
	
	def test_nested_scope_modules
		this_class = TestClass
		assert_includes(this_class.constants, :ClassMethods)
#!		assert_includes(this_class.constants, :DefinitionalConstants)
#!		assert_includes(this_class.constants, :Constructors)
#!		assert_includes(this_class.constants, :ReferenceObjects)
		assert_includes(this_class.constants, :Assertions)
				nested_constants = this_class.constants.map do |m|
					trial_eval = eval(this_class.name.to_s + '::' + m.to_s)
					if trial_eval.kind_of?(Module)
						trial_eval
					else
						nil
					end # if
				end.compact # map

		assert_includes(nested_constants, this_class::ClassMethods)
#!		assert_includes(nested_constants, this_class::DefinitionalConstants)
#!		assert_includes(nested_constants, this_class::Constructors)
#!		assert_includes(nested_constants, this_class::ReferenceObjects)
		assert_includes(nested_constants, this_class::Assertions)

		assert_includes(this_class.nested_scope_modules, this_class::ClassMethods)
#!		assert_includes(this_class.nested_scope_modules, this_class::DefinitionalConstants)
#!		assert_includes(this_class.nested_scope_modules, this_class::Constructors)
#!		assert_includes(this_class.nested_scope_modules, this_class::ReferenceObjects)
		assert_includes(this_class.nested_scope_modules, this_class::Assertions)
#!		assert_equal(this_class::ClassInterface, Dry::Types::Struct::ClassInterface)
#!		refute_includes(this_class.nested_scope_modules, Dry::Types::Struct::ClassInterface)
	end # nested_scope_modules
			
	def test_nested_scope_module_names
		this_class = TestClass
#!		assert_includes(this_class.nested_scope_module_names, (this_class.name + '::ClassMethods').to_sym)
#!		assert_includes(this_class.nested_scope_module_names, (this_class.name + '::DefinitionalConstants').to_sym)
#!		assert_includes(this_class.nested_scope_module_names, (this_class.name + '::Constructors').to_sym)
#!		assert_includes(this_class.nested_scope_module_names, (this_class.name + '::ReferenceObjects').to_sym)
#!		assert_includes(this_class.nested_scope_module_names, (this_class.name + '::Assertions').to_sym)
#!		assert_includes(this_class.constants, :Minimal_object)
	end # nested_scope_module_names
			
			def test_assert_nested_scope_submodule
				this_class = TestClass
#!				this_class.assert_nested_scope_submodule((this_class.name + '::ClassMethods').to_sym)
#				this_class.assert_nested_scope_submodule((this_class.name + '::DefinitionalConstants').to_sym)
#				this_class.assert_nested_scope_submodule((this_class.name + '::Constructors').to_sym)
#				this_class.assert_nested_scope_submodule((this_class.name + '::ReferenceObjects').to_sym)
#!				this_class.assert_nested_scope_submodule((this_class.name + '::Assertions').to_sym)
			end # assert_included_submodule
			
			def test_assert_included_submodule
				this_class = TestClass
#!class				this_class.assert_included_submodule((this_class.name + '::ClassMethods').to_sym)
#				this_class.assert_included_submodule((this_class.name + '::DefinitionalConstants').to_sym)
#!class				this_class.assert_included_submodule((this_class.name + '::Constructors').to_sym)
#				this_class.assert_included_submodule((this_class.name + '::ReferenceObjects').to_sym)
#!				this_class.assert_included_submodule((this_class.name + '::Assertions').to_sym)
			end # assert_included_submodule
			
			def test_assert_nested_and_included
				this_class = TestClass
#!class				this_class.assert_nested_and_included((this_class.name + '::ClassMethods').to_sym)
#				this_class.assert_nested_and_included((this_class.name + '::DefinitionalConstants').to_sym)
#!class				this_class.assert_nested_and_included((this_class.name + '::Constructors').to_sym)
#				this_class.assert_nested_and_included((this_class.name + '::ReferenceObjects').to_sym)
#!				this_class.assert_nested_and_included((this_class.name + '::Assertions').to_sym)
			end # assert_nested_and_included
			
  def test_Minimal_assert_pre_conditions
		this_class = TestClass
#		this_class.assert_pre_conditions
		message = ''
#		my_style_modules = [this_class::Assertions, this_class::ReferenceObjects, this_class::DefinitionalConstants]
#!		my_style_module_names = my_style_modules.map{|m| m.name.to_sym}
#		assert_includes(my_style_module_names, (this_class.name + '::ReferenceObjects').to_sym, message)
#		assert_includes(my_style_module_names, (this_class.name + '::DefinitionalConstants').to_sym, message)
#!		assert_includes(my_style_module_names, (this_class.name + '::Assertions').to_sym, message)

		super_class = this_class.superclass
		superclass_modules = super_class.included_modules
		superclass_module_names = super_class.included_modules.map(&:module_name)
		message = ''
#		assert_includes(super_class.included_modules.map(&:module_name), :'Dry::Equalizer::Methods', message)
		assert_includes(super_class.included_modules.map(&:module_name), :'JSON::Ext::Generator::GeneratorMethods::Object', message)
#! ruby 2.4		assert_includes(Module.used_modules.map(&:module_name), :'JSON::Ext::Generator::GeneratorMethods::Object', message)
  end # assert_pre_conditions
end # Cache

class CloneTest < TestCase
  def test_clone_state
    hidden_clone_answer = [[{ { dup: :hash } => true },
                            { { dup: :inspect } => true },
                            { { dup: :object_id } => false }],
                           [{ { clone: :hash } => true },
                            { { clone: :inspect } => true },
                            { { clone: :object_id } => false }]]
    assert_equal(hidden_clone_answer, 'a'.clone_state)
    #		assert_equal(hidden_clone_answer, CA_current_year.clone_state)
    # !		assert_equal(hidden_clone_answer, TestClass.new.freeze.clone_state)
    # !		assert_equal(hidden_clone_answer, TestClass.new.clone_state)
  end # clone_state

  def test_assert_clone_state
    'a'.assert_clone_state
    #		CA_current_year.assert_clone_state
    TestClass.new.freeze.assert_clone_state
    TestClass.new.assert_clone_state
    #		US1040_user.assert_clone_state
  end # assert_clone_state

  def test_clone_explain
    assert_equal('', 'a'.clone_explain)
  end # clone_explain
end # Clone
