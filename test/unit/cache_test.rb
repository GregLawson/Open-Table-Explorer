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
		end # TestClass

class CacheTest < TestCase
  include RubyAssertions

	def test_clone_state
		hidden_clone_answer = [[{{:dup=>:hash}=>true},
  {{:dup=>:inspect}=>true},
  {{:dup=>:object_id}=>false}],
 [{{:clone=>:hash}=>true},
  {{:clone=>:inspect}=>true},
  {{:clone=>:object_id}=>false}]]
		assert_equal(hidden_clone_answer, 'a'.clone_state)
#		assert_equal(hidden_clone_answer, CA_current_year.clone_state)
#!		assert_equal(hidden_clone_answer, TestClass.new.freeze.clone_state)
#!		assert_equal(hidden_clone_answer, TestClass.new.clone_state)
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
	
	def test_cache
		object = TestClass.new.freeze
#		object = CA_current_year
#!		object = object.clone
		cache_name = :test
		assert_raise(RuntimeError) { object.cache(:test)}
#!		block = 
		cache_const_name = ('Cached_' + cache_name.to_s).to_sym
		assert_equal(:Cached_test, cache_const_name)
		refute(object.class.const_defined?(cache_const_name))
		ret = 2
		refute(object.class.const_defined?(cache_const_name))
		object.class.const_set(cache_const_name, ret)
		assert(object.class.const_defined?(cache_const_name))
		assert_equal(2, object.class.const_get(cache_const_name))
		refute_nil(object.cache(:test){|| 2}, object.inspect)
		assert_equal(2, object.cache(:test){|| 2})
		assert_equal(2, object.class.const_get(cache_const_name), object.class.const_get(cache_const_name))
	end # cache
end # Cache
