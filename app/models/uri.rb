###########################################################################
#    Copyright (C) 2011-2017 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../../app/models/no_db.rb'
#require_relative '../../app/models/generic_table.rb' # in test_helper?
#require_relative '../../app/models/stream_method.rb'
require 'virtus'
require_relative '../../app/models/ruby_lines_storage.rb'
require_relative '../../app/models/shell_command.rb'
module URI

	class FILE < Generic
		COMPONENT =  [:scheme, :userinfo, :host, :port, :registry, :path, :opaque, :query, :fragment]
		def open
			begin
				if opaque
					File.open(opaque)
				else
					File.open(path)
				end # if
			rescue StandardError => exception_object
			 {uri: self, exception_object: exception_object, backtrace_locations: exception_object.backtrace_locations}
			end # begin / rescue
		end # FILE_open
	end # FILE
	@@schemes['FILE'] = FILE

	class SHELL < Generic
		def open


			Shell::Command.new(command_string: opaque).start.close
		end # open
	end # SHELL
	@@schemes['SHELL'] = SHELL

  module DefinitionalClassMethods # if reference by DefinitionalConstants or not referenced
		def logical_primary_key
			[:href]	# logically the link name is the part that is visible and should be the unique name
		end # logical_primary_key

		def component_hash
			ret = {}
			URI.scheme_list.values.map do |klass|
				ret.merge!({klass => klass::COMPONENT})
			end # map
			ret
		end # component_hash
		
		def opaque_schemes
			URI.component_hash.keys.select do |scheme_capitalized|
				URI.component_hash[scheme_capitalized].include?(:opaque)
			end # each
		end # opaque_schemes
		
		def registry_schemes
			URI.component_hash.keys.select do |scheme_capitalized|
				URI.component_hash[scheme_capitalized].include?(:opaque)
			end # each
		end # registry_schemes
  end # DefinitionalClassMethods
  extend DefinitionalClassMethods

  def uriComponent(componentName)
    ret = select(componentName)
    if ret.class == Array
      ret.map do |mostly_redundant_array|
				if mostly_redundant_array.nil?
					nil
				else
					mostly_redundant_array
				end # if
			end[0] # map
    else
      return ret
    end
  end # uriComponent

  def uriHash
    componentNames = self.class::COMPONENT
    hash = {}
    componentNames.each_index do |i|
      componentName = componentNames[i]
      component = uriComponent(componentName)
      unless component.nil?
        hash.merge!(componentName => component)
      end # if
    end # each_index
    hash
  end # uriHash

	def state
		{regexp: parser.regexp,
 			klass: self.class,
			componentNames: self.class::COMPONENT,
			rebuilt: self.class.build(uriHash).to_s,
			uri_to_s: self.to_s,
			uriHash: uriHash,
			opaque_include: self.class::COMPONENT.include?(:opaque),
			registry_include: self.class::COMPONENT.include?(:registry)
			}
	end # state

	def explain

		state.ruby_lines_storage
	end # explain
end # URI

class UriParse
	include URI

	module DefinitionalConstants # constant parameters in definition of the type (suggest all CAPS)
		Optional_uri_components = [:userinfo, :host, :port, :registry, :opaque, :query, :fragment]
	end # DefinitionalConstants
	include DefinitionalConstants
	
	  include Virtus.value_object
		values do

    attribute :initialization_string, String
		end # values
		
  def uri
		URI.parse(@initialization_string)
  end # uri
	
	def component_names
		uri.class::COMPONENT
	end # component_names
	
	def state
		{ uri: uri.state,
			uriArray: URI.split(URI.escape(@initialization_string)),
			initialization_string: @initialization_string, 
			opaque_split: URI.split(@initialization_string)[6],
			registry_split: URI.split(@initialization_string)[4],
			frozen: frozen?
			}
	end # state
	
	def explain
		ret = "'" + @initialization_string + "'"
		if well_formed?
			 ret += ' is well formed ' + uri.uriHash.inspect
		end # if
		if registry?
			 ret += ' has a registry.' + state.ruby_lines_storage
		elsif opaque?
			 ret += ' is opaque.' + state.ruby_lines_storage
		else
			state.ruby_lines_storage
		end # if
	end # explain
	
	def inspect
		explain
	end # inspect

  def uriArray
    URI.split(@initialization_string)
  end # uriArray

		def opaque?
			!state[:opaque_split].nil?
    end # opaque?

		def registry?
			!state[:registry_split].nil?
    end # registry?

	def well_formed?
			@initialization_string == uri.class.build(uri.uriHash).to_s
	end # well_formed?
	
	require_relative '../../app/models/assertions.rb'
#  require_relative '../../test/assertions/ruby_assertions.rb'
#  require_relative '../../test/assertions/default_assertions.rb'
  module Assertions
#    include DefaultAssertions
    module ClassMethods
#      include DefaultAssertions::ClassMethods
      def assert_pre_conditions
				assert_includes(URI.scheme_list, 'HTTP')
				assert_includes(URI.scheme_list, 'FILE')
				assert_includes(URI.scheme_list, 'SHELL')
  end # assert_UriParse_pre_conditions
    end # ClassMethods
		
    def assert_pre_conditions
      assert_instance_of(UriParse, self)
			assert_equal(9, URI.split(@initialization_string).size, explain)
#			assert_equal(uri.class::COMPONENT.size, uri.class.split(@initialization_string).size, explain)
			uri.class::COMPONENT.each do |component_name|
				component = uri.select(component_name)
				assert_instance_of(Array, component, explain)
				assert_equal(1, component.size, explain)
				if component[0].nil?
					assert_instance_of(NilClass, component[0], explain)
				elsif component[0].instance_of?(Fixnum)
					assert_equal(:port, component_name, explain)
				elsif component[0].instance_of?(Array)
					assert_equal(:headers, component_name, explain)
				else
					assert_instance_of(String, component[0], explain)
				end # end
				method = uri.method(component_name)
#				assert_equal(component, [method.call])
			end # each
			refute_nil(uri.scheme, explain)
			assert_includes(URI.scheme_list.keys + ['GENERIC'], uri.scheme.upcase, explain)
			assert_equal(uri, URI.join(URI.parse(@initialization_string)), explain)
			refute(frozen?, explain)
#			assert_equal(@initialization_string, uri.to_s, explain)
    end # assert_pre_conditions
		
		def refute_opaque
			assert(!opaque?, explain)
    end # refute_opaque

		def assert_opaque
			assert(opaque?, explain)
    end # assert_opaque
		
		def refute_registry
			assert(!registry?, explain)
    end # refute_registry

		def assert_registry
			assert(registry?, explain)
    end # assert_registry

	def assert_well_formed
		assert(well_formed?, state.ruby_lines_storage)
	end # assert_well_formed
	
	def refute_well_formed
		refute(well_formed?, explain)
#		assert_opaque
	end # refute_well_formed
	
  end # Assertions
  include Assertions
  extend Assertions::ClassMethods
end # UriParse
