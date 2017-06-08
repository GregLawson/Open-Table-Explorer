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
require_relative '../assertions/ruby_assertions_test_unit.rb'

class TestClass
  include Cache
  extend Cache::ClassMethods
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

class CacheTest < TestCase
  include RubyAssertions

	def setup
		TestClass.clear_cache(:make_class_cache)
  end # setup

  def teardown
  end # teardown

  def test_cache_const_name
    assert_equal(:@cached_test, TestClass.new.cache_const_name(:test))
    assert_equal(:Cached_make_class_cache, TestClass.cache_const_name(:make_class_cache))
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
    object = TestClass.new
    cache_name = :test
    assert_equal(':test is not cached as instance variable :@cached_test in []', object.explain_cache(cache_name))
    assert_equal(2, object.cache(cache_name) { || 2 })
    assert_equal(':test is cached as instance variable :@cached_test = 2', object.explain_cache(cache_name))
    assert_equal(':junk is not cached as instance variable :@cached_junk in [:@cached_test]', object.explain_cache(:junk))

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

  def test_assert_cached
    object = TestClass.new
    cache_name = :test
    assert_equal(2, object.cache(cache_name) { || 2 })
    object.assert_cached(cache_name)
    TestClass.refute_cached(:cache, TestClass.constants.inspect)
    TestClass.make_class_cache
    TestClass.refute_cached(:cache, TestClass.constants.inspect)
    TestClass.assert_cached(:make_class_cache, TestClass.constants.inspect)
  end # assert_cached

  def test_refute_cached
    TestClass.refute_cached(:cache)
    object = TestClass.new
    cache_name = :test
    object.refute_cached(cache_name)
    TestClass.refute_cached(:make_class_cache)
  end # refute_cached
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
