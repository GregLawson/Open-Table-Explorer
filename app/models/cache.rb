###########################################################################
#    Copyright (C) 2011-2017 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
# require 'pathname'
# need  sudo apt-get install poppler-utils
# need nodejs
# need sudo apt-get install pdftk
# require_relative '../../app/models/no_db.rb'
require_relative '../../app/models/shell_command.rb'
require_relative '../../app/models/repository.rb'
require_relative '../../app/models/parse.rb'
require 'dry-types'
module Types
	include Dry::Types.module
end # Types
#! require 'virtus'

module Cache
	
	def cache_const_name(cache_name)
		if self.class == Class
			('Cached_' + cache_name.to_s).to_sym
		else
			('@cached_' + cache_name.to_s).to_sym
		end # if
	end # cache_const_name
	
	def cached?(cache_name)
		if self.class == Class
			self.class.const_defined?(cache_const_name(cache_name))
		else
			self.instance_variable_defined?(cache_const_name(cache_name))
		end # if
	end # cached?
	
	def cache(cache_name = __callee__, &block)
		unless block_given?
			raise 'caching ' + cache_name.to_s + 'requires a block.'
		else
			if self.class == Class
				if cached?(cache_name)
					self.class.const_get(cache_const_name(cache_name))
				else
					ret = block.call
					self.class.const_set(cache_const_name(cache_name), ret)
				end # if
			else
				if cached?(cache_name)
					self.instance_variable_get(cache_const_name(cache_name))
				else
					ret = block.call
					self.instance_variable_set(cache_const_name(cache_name), ret)
				end # if
			end # if 
		end # unless
	end # cache

	def explain_cache(cache_name)
		if cached?(cache_name)
			if self.class == Class
				cache_name.inspect + ' is cached as constant ' + self.class.name + '::' + cache_const_name(cache_name).to_s + ' = ' + self.class.const_get(cache_const_name(cache_name)).inspect
			else
				cache_name.inspect + ' is cached as instance variable '  + cache_const_name(cache_name).inspect + ' = ' + instance_variable_get(cache_const_name(cache_name)).inspect
			end # if
		else
			cache_name.inspect + ' is not cached in ' + self.class.constants.inspect
			if self.class == Class
				cache_name.inspect + ' is not cached as constant ' + self.class.name + '::' + cache_const_name(cache_name).to_s + ' in ' + self.class.constants.inspect
			else
				cache_name.inspect + ' is not cached as instance variable '  + cache_const_name(cache_name).inspect + ' in ' + instance_variables.inspect
			end # if
		end # if
	end # explain_cache
		
	def clear_cache(cache_name)
		self.class.const_set(cache_const_name(cache_name), nil)
	end # clear_cache
	
	def assert_cached(cache_name)
		assert(cached?(cache_name), explain_cache(cache_name))
	end # assert_cached
	
	def refute_cached(cache_name)
		refute(cached?(cache_name), explain_cache(cache_name))
	end # refute_cached
end # Cache

class Object
	def clone_state
#		ret = {}
		[ :dup, :clone ].map do |copy_method|
			mutable_object = send(copy_method)
			[ :hash , :inspect, :object_id].map do |attribute|
				{ {copy_method => attribute} => send(attribute) == mutable_object.send(attribute) }
			end # each
		end # each
	end # clone_state
	
	def assert_clone_state
		dup_object = dup
		clone_object = clone
		# dup copies taint
		# clone copies internal stste, dup creates new object
		unless frozen? # test unit modifies object
			assert_equal(tainted?, clone_object.tainted?, clone_state.inspect)
			assert_equal(tainted?, dup_object.tainted?, clone_state.inspect)
			assert_equal(frozen?, dup_object.frozen?, clone_state.inspect)
			refute_equal(object_id, dup_object.object_id, dup_object.inspect)
			refute_equal(object_id, clone_object.object_id, clone_state.inspect)
#!			assert_equal(self, clone_object, clone_object.clone_explain)
#!			assert_equal(self, dup_object, dup_object.clone_explain)
		end # unless
	end # assert_clone_state

	def clone_explain
		ret = []
		dup_object = dup
		clone_object = clone
		ret << 'clone hash not equal' if hash != clone_object.hash
		ret << 'dup hash not equal' if hash != dup_object.hash
		ret << 'dup inspect not equal' if inspect != dup_object.inspect
		ret << 'clone inspect not equal' if inspect != clone_object.inspect
		ret.join(', ')
	end # clone_explain
end # Object