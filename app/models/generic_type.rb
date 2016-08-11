###########################################################################
#    Copyright (C) 2011-2016 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../../app/models/no_db.rb'
#require 'rom-yaml' # obsolete version 8/6/2016, conflicts with rom-sql and rom-csv
#require 'rom-csv' # obsolete version 8/6/2016, conflicts with rom-sql and rom-rom
require 'rom' # how differs from rom-sql
require 'rom-sql' # conflicts with rom-csv and rom-rom
#require 'rom-relation' # conflicts with rom-csv and rom-rom
require 'rom-repository' # conflicts with rom-csv and rom-rom
require 'dry-types'
module Types
	include Dry::Types.module
end # Types
require_relative '../../app/models/generic_column.rb'
require 'yaml' # before parse.rb
require_relative '../../app/models/parse.rb'
#require_relative '../../app/models/regexp_tree.rb'
# 1a) a regexp should match all examples from itself down the specialization tree.
# 1b) an example should match its regexp and all generalization regexps above if
# 2) an example should not match at least one of its specialization regexps
# 3) example  strings should not equal specialization examples
# 4) specialization regexps have fewer choices (including case) or more restricted repetition

class GenericType < Dry::Types::Value
  extend NoDB::ClassMethods
#  has_many :example_types
#  has_many :specialize, class_name: 'GenericType',
#                        foreign_key: 'generalize_id'
#  belongs_to :generalize, class_name: 'GenericType',
#                          foreign_key: 'generalize_id'
#require 'test/assertions/ruby_assertions.rb'
	
  module DefinitionalClassMethods
		def primary_key_index
#			data_source_yaml('generic_types').values.map do |r|
#				GenericType.new(r)
#			end # map
			yaml_table_name = 'generic_types'
			data_source_file = 'test/fixtures/' + yaml_table_name + '.yml'
      yaml = YAML.load(File.open(data_source_file))
			ret = {}
			yaml.each_pair do |key, value|
				if key.nil?
					raise 'key is nil. value =  ' + value.inspect
				end # if
				if value.nil?
					raise 'value is nil. key =  ' + value.inspect
				end # if
				lookup_name = value['import_class']
				if lookup_name.nil?
					raise 'import_class with ' + key.inspect + ' not in ' + value.keys.join(', ')
				else
					name = lookup_name.to_sym
				ret[name] = GenericType.new(name: name,
														data_regexp: Regexp.new(value['data_regexp']),
														generalize: value['generalize'].to_sym,
														rails_type: value['rails_type'],
														ruby_conversion: value['ruby_conversion'] 
													)
				end # if
			end # each_pair
			ret
		end # primary_key_index
  end # DefinitionalClassMethods
  extend DefinitionalClassMethods

    attribute :name, Types::Strict::Symbol | Types::Strict::String
		attribute :data_regexp, Types::Coercible::String
		attribute :generalize, Types::Strict::Symbol | Types::Strict::String
#		attribute :generalize, GenericType
		attribute :rails_type, Types::Strict::String.optional
		attribute :ruby_conversion, Types::Strict::String.optional
	
	module DefinitionalConstants # constant parameters of the type (suggest all CAPS)
		Primary_key_index = GenericType.primary_key_index.freeze

  end # DefinitionalConstants
  include DefinitionalConstants
	
  module DefinitionalClassMethods
		def all
			DefinitionalConstants::Primary_key_index.values
		end # all

  def logical_primary_key
    [:name]
  end # logical_primary_key
 
  def find_by_name(macro_name)
    DefinitionalConstants::Primary_key_index[macro_name.to_sym]
end #find_by_name
	
# Define some constants, after find_by_name redefinition
  end # DefinitionalClassMethods
  extend DefinitionalClassMethods
	
  module Constructors # such as alternative new methods
    include DefinitionalConstants
  end # Constructors
  extend Constructors
	
  module ReferenceObjects # constant objects of the type (e.g. default_objects)
    include DefinitionalConstants
		Text = GenericType.find_by_name('Text_Column')
		Most_general = Text

	  Ascii = GenericType.find_by_name('ascii')
  end # ReferenceObjects
  include ReferenceObjects
	
	def generalizations(previous_generalizations = [])
		if most_general?
			previous_generalizations
		else
			generalized_generic_type = GenericType.find_by_name(generalize)
			one_more_recursion = (previous_generalizations << generalized_generic_type).uniq
			if generalized_generic_type.most_general?
				return one_more_recursion # terminate 
			else
				if previous_generalizations.map(&:name).include?(@name)
					previous_generalizations
				else
				
					if one_more_recursion.map(&:name).include?(@name)
						previous_generalizations
					end #if
								
					generalized_generic_type.generalizations(one_more_recursion)
				end # if
			end # if
		end #if
	end # generalizations

def most_general?
    @generalize.nil? || @generalize == '' || @generalize.to_sym == @name
end #most_general

	def specialize
		GenericType.all.select do |generic_type|
			if generic_type.most_general?
				false
			else
				generic_type.generalize.to_sym == @name
			end # if
		end # select
	end # specialize
	
def unspecialized?
    specialize.empty?
	end # unspecialized?

# find Array of more specific types (tree children)
def one_level_specializations
    if most_general?
		return specialize-[self]
    elsif unspecialized?
		return []
	else
		specialize
	end #if
end #one_level_specializations

	def recursive_specializations
		if unspecialized?
			return []
		else
			one_more_recursion = specialize.map{|s| s.recursive_specializations}.flatten.uniq 
			ret = (one_more_recursion + one_level_specializations).uniq - [self]
			if ret.include?(self)
				raise 'recursion danger at ' + ret.inspect
			else
				ret
			end # if
		end #if
	end # recursive_specializations

  def expansion_termination?
#    regexp = self[:data_regexp]
#    parse = RegexpTree.new(regexp)
#    macro_name = parse.macro_call?
#    name == macro_name
  end # expansion_termination

  def expand
#    parse = RegexpTree.new(self[:data_regexp])
    if expansion_termination?
#      return parse[0] # terminates recursion
    else # possible expansions
#      parse.map_branches do |branch|
#        macro_name = parse.macro_call?(branch)
#        if macro_name
#          macro_generic_type = GenericType.find_by_name(macro_name)
#          macro_call = macro_generic_type[:data_regexp]
#          macro_generic_type.expand
#        else
#          branch
#        end # if
#      end # map_branches
    end # if possible expansions
  end # expand

  # Matches expanded regexp against full string
  # Sets EXTENDED format (whitespace and comments) and MULTILINE (newlines are just another character)
  # Calls expand above.
  def match_exact?(string_to_match)
    regexp = Regexp.new('^' + @data_regexp.to_s + '$', Regexp::EXTENDED | Regexp::MULTILINE)
		string_to_match.capture?(regexp)
  end # match_exact

  # Matches string from beginning against expanded Regexp
  # Sets EXTENDED format (whitespace and comments) and MULTILINE (newlines are just another character)
  # Calls expand above.
  def match_start?(string_to_match)
    regexp = Regexp.new('^' + @data_regexp.to_s, Regexp::EXTENDED | Regexp::MULTILINE)
		string_to_match.capture?(regexp)
  end # match_start

  # Matches expanded regexp from start of string
  # Sets EXTENDED format (whitespace and comments) and MULTILINE (newlines are just another character)
  # Calls expand above.
  def match_end?(string_to_match)
    regexp = Regexp.new(@data_regexp.to_s + '$', Regexp::EXTENDED | Regexp::MULTILINE)
		string_to_match.capture?(regexp)
  end # match_end

  # Matches expanded regexp anywhere in string
  # Sets EXTENDED format (whitespace and comments) and MULTILINE (newlines are just another character)
  # Calls expand above.
  def match_any?(string_to_match)
    regexp = Regexp.new(@data_regexp.to_s, Regexp::EXTENDED | Regexp::MULTILINE)
		string_to_match.capture?(regexp)
  end # match_any

  # Find specializations that match recursively
  # Returns an (nested?) Array of GenericType
  # Least specialized comes first
  # Multiple specializations that match at the same level are probably not handled correcly yet.
	def specializations_that_match?(string_to_match)
		ret=[]
		one_level_specializations.map do |specialization|
				next unless specialization.match_exact?(string_to_match)
				ret.push(specialization)
				unless specialization.unspecialized?
					specializations=specialization.specializations_that_match?(string_to_match)
					unless specializations.empty?
						ret.push(specializations)
					end #if
				end #if
				# if
		end .compact.uniq #map
			[ret]
	end #specializations_that_match

def possibilities?(common_matches)
    if common_matches.instance_of?(GenericType)
		common_matches
    elsif common_matches.is_a?(Array)
      if common_matches[1].is_a?(Array)
			Array.new(possibilities?(common_matches[1])+possibilities?(common_matches[2..-1]))
		else
			Array.new(common_matches)
		end #if
	end #if
end #possibilities

def most_specialized?(string_to_match, common_matches=common_matches?(string_to_match))
    if common_matches.include?(self)
		possibilities?(common_matches)
	else
		possibilities?([self, common_matches])
	end#if
end #most_specialized

# Recursively search where in the tree a string matches
# Returns an array of GenericType instances.
# The last element of the array matched.
# The receiving object is a GenericType instance used as an starting place in the tree.
# If the receiving object matched it will be the first element in returned array.
# If the string doesn't match the receiving object, generalize is returned.
# If start matches, the returned array will be the ordered array of matching specializations.
# Calls match_exact? and specializations_that_match? above
def common_matches?(string_to_match)
	if match_exact?(string_to_match)
		if unspecialized?
			return [[self]]
		else
			specializations=specializations_that_match?(string_to_match)
			if specializations.empty?
				[[self]]
			else
				[[self]] << specializations
			end #if
		end #if
	else
		generalize.common_matches?(string_to_match)
	end #if
end #common_matches
	
  require_relative '../../app/models/assertions.rb'
  module Assertions
    module ClassMethods
      def assert_pre_conditions(message = '')
        message += "In assert_pre_conditions, self=#{inspect}"
        #	asset_nested_and_included(:ClassMethods, self)
        #	asset_nested_and_included(:Constants, self)
        #	asset_nested_and_included(:Assertions, self)
				assert_equal(GenericType.primary_key_index, GenericType.primary_key_index)
				assert_equal(GenericType.primary_key_index.keys, GenericType::DefinitionalConstants::Primary_key_index.keys)
				assert_equal(GenericType.primary_key_index, GenericType::DefinitionalConstants::Primary_key_index)
        self
      end # assert_pre_conditions

      def assert_post_conditions(message = '')
        message += "In assert_post_conditions, self=#{inspect}"
        self
      end # assert_post_conditions
    end # ClassMethods

    def assert_pre_conditions(message = '')
      message += "In assert_pre_conditions, self=#{inspect}"
#			refute_nil(@name, 'name expected to not be nil. ' + inspect)
#			refute_nil(@data_regexp, inspect)
#			refute_nil(@generalize, inspect)
#			refute_nil(@rails_type, inspect)
#			refute_nil(@ruby_conversion, inspect)	
				self # return for command chaining
    end # assert_pre_conditions

    def assert_post_conditions(message = '')
      message += "In assert_post_conditions, self=#{inspect}"
				self # return for command chaining
    end # assert_post_conditions
		
		def assert_no_generalize_cycle(previous_generalizations = [])
      message = "In assert_no_generalize_cycle, self=#{inspect}"
			assert_pre_conditions(message + "\nin assert_pre_conditions")
			previous_generalizations.each {|g| g.assert_pre_conditions}
			if most_general? # recursion termination condition
				previous_generalizations
			else
				generalized_generic_type = GenericType.find_by_name(@generalize)
#				assert_instance_of(GenericType, generalized_generic_type, inspect + "\n" + generalize.inspect + ' not in ' + GenericType.all.map(&:name).map(&:to_s).join(', '))
				one_more_recursion = (previous_generalizations + [generalized_generic_type]).uniq
				if generalized_generic_type.most_general?
#					puts "generalized_generic_type.most_general? = "  + generalized_generic_type.most_general?.inspect
					return one_more_recursion # terminate 
				else
#					puts 'generalized_generic_type.generalize =' + generalized_generic_type.generalize.inspect
#					puts "generalize = " + generalize.inspect
					if previous_generalizations.map(&:name).include?(@generalize.to_sym)
						message = "\n" + 'There is a cycle in the generalizations for ' + inspect
						message += "\n" + 'previous_generalizations = ' + previous_generalizations.map(&:name).map(&:to_s).join(', ')
						message += "\n" + 'reverse engiuneering previous call'
						message += "\n" + 'one_more_recursion = ' + previous_generalizations.map(&:name).map(&:to_s).join(', ')
#						message += "\n" + 'generalized_generic_type = ' + self.map(&:name).map(&:to_s).join(', ')
#						message += "\n" + 'self = ' + self.map(&:name).map(&:to_s).join(', ')
						raise message
						previous_generalizations
					else
						message = "\n" + 'There is a cycle in the generalizations for ' + inspect
						message += "\n" + 'one_more_recursion = ' + one_more_recursion.map(&:name).map(&:to_s).join(', ')
#						raise message
						generalized_generic_type.assert_no_generalize_cycle(one_more_recursion)
					end #if
					end # if
				end # if
#			self # return for command chaining
		end # assert_no_generalize_cycle
  end # Assertions
  include Assertions
  extend Assertions::ClassMethods
	
#  self.assert_pre_conditions
	
  module Examples # usually constant objects of the type (easy to understand (perhaps impractical) examples for testing)
    include DefinitionalConstants
    include ReferenceObjects
  end # Examples
end # GenericType

class GenericTypeRepo < ROM::Repository[:generic_types]
	commands :create

  module DefinitionalClassMethods
		def primary_key_index
#			data_source_yaml('generic_types').values.map do |r|
#				GenericType.new(r)
#			end # map
			yaml_table_name = 'generic_types'
			data_source_file = 'test/fixtures/' + yaml_table_name + '.yml'
      yaml = YAML.load(File.open(data_source_file))
			ret = {}
			yaml.each_pair do |key, value|
				if key.nil?
					raise 'key is nil. value =  ' + value.inspect
				end # if
				if value.nil?
					raise 'value is nil. key =  ' + value.inspect
				end # if
				lookup_name = value['import_class']
				if lookup_name.nil?
					raise 'import_class with ' + key.inspect + ' not in ' + value.keys.join(', ')
				else
					name = lookup_name.to_sym
				ret[name] = GenericTypeRepo::Generic_type_repo.create(name: name,
														data_regexp: value['data_regexp'],
														generalize: value['generalize'],
														rails_type: value['rails_type'],
														ruby_conversion: value['ruby_conversion'] 
													)
				end # if
			end # each_pair
			ret
		end # primary_key_index
  end # DefinitionalClassMethods
  extend DefinitionalClassMethods


	module Relations
		class GenericTypes < ROM::Relation[:sql]
		end # GenericTypes

		class GenericCoercions < ROM::Relation[:sql]
		end # GenericCoercions

		class GenericDBTypes < ROM::Relation[:sql]
		end # GenericDBTypes
	end # Relations
	
	module DefinitionalConstants # constant parameters of the type (suggest all CAPS)
		Db_filename = 'db/' + Unit::Executable.model_basename.to_s + '.sqlite3'
		Sql_pathname = 'sqlite:' + Db_filename
		Config = ROM::Configuration.new(:sql, Sql_pathname)
		Container = ROM::container(:sql, Sql_pathname) do |conf|
			conf.default.create_table(:generic_types) do
				primary_key :id
				column :name, String
				column :data_regexp, String
				column :generalize, String
		#		column :generalize, GenericType
				column :rails_type, String
				column :ruby_conversion, String
			end # create_table
		end # container
#		Container = ROM.container(Config)
		Generic_type_repo = GenericTypeRepo.new(Container)

  end # DefinitionalConstants
  include DefinitionalConstants
	
	def most_general?
			@generalize.nil? || @generalize == '' || @generalize == @name
	end #most_general
	
	def coerce(record)
		GenericType.new(name: record.name,
														data_regexp: Regexp.new(record.data_regexp),
														generalize: record.generalize.to_sym,
														rails_type: record.rails_type,
														ruby_conversion: record.ruby_conversion
													)

	end # coerce
	
	def all
		generic_types.as(GenericType).to_a
	end # all

	def by_id(id)
		generic_types.as(GenericType).fetch(id)
	end # by_id
	
	def by_name(name)
		generic_types.where(name: name).as(GenericType)
	end # by_name
	
  require_relative '../../app/models/assertions.rb'
  module Assertions
    module ClassMethods
      def assert_pre_conditions(message = '')
        message += "In assert_pre_conditions, self=#{inspect}"
        self
      end # assert_pre_conditions

      def assert_post_conditions(message = '')
        message += "In assert_post_conditions, self=#{inspect}"
				assert_equal([:@environment, :@setup], GenericTypeRepo::Config.instance_variables, GenericTypeRepo::Config.inspect)
				assert_instance_of(Hash, GenericTypeRepo::Config.gateways, GenericTypeRepo::Config.gateways.inspect)
				assert_equal([:default], GenericTypeRepo::Config.gateways.keys, GenericTypeRepo::Config.gateways.inspect)
				assert_include(GenericTypeRepo::Config.gateways[:default].instance_variables, :@connection, GenericTypeRepo::Config.gateways[:default].inspect)
				assert_include(GenericTypeRepo::Config.gateways[:default].instance_variables, :@migrator, GenericTypeRepo::Config.gateways[:default].inspect)
				assert_include(GenericTypeRepo::Config.gateways[:default].instance_variables, :@options, GenericTypeRepo::Config.gateways[:default].inspect)
				assert_equal([:@gateways, :@relations, :@mappers, :@commands], GenericTypeRepo::Container.instance_variables, GenericTypeRepo::Container.inspect)
				assert_instance_of(GenericTypeRepo, GenericTypeRepo::Generic_type_repo)
				assert_include(GenericTypeRepo::Generic_type_repo.instance_variables, :@container, GenericTypeRepo::Generic_type_repo.inspect)
				assert_include(GenericTypeRepo::Generic_type_repo.instance_variables, :@mappers, GenericTypeRepo::Generic_type_repo.inspect)
				assert_include(GenericTypeRepo::Generic_type_repo.instance_variables, :@generic_types, GenericTypeRepo::Generic_type_repo.inspect)
				assert_include(GenericTypeRepo::Generic_type_repo.instance_variables, :@relations, GenericTypeRepo::Generic_type_repo.inspect)
				assert_include(GenericTypeRepo::Generic_type_repo.instance_variables, :@root, GenericTypeRepo::Generic_type_repo.inspect)
				assert_include(GenericTypeRepo::Generic_type_repo.instance_variables, :@__commands__, GenericTypeRepo::Generic_type_repo.inspect)
				assert_equal(GenericTypeRepo::Generic_type_repo.relations.instance_variables, [:@elements, :@name], GenericTypeRepo::Generic_type_repo.inspect)
				assert_equal([:generic_types], GenericTypeRepo::Generic_type_repo.relations.elements.keys, GenericTypeRepo::Generic_type_repo.inspect)
        self
      end # assert_post_conditions
    end # ClassMethods

    def assert_pre_conditions(message = '')
      message += "In assert_pre_conditions, self=#{inspect}"
			refute_nil(@name, 'name expected to not be nil. ' + inspect)
			refute_nil(@data_regexp, inspect)
			refute_nil(@generalize, inspect)
#			refute_nil(@rails_type, inspect)
			refute_nil(@ruby_conversion, inspect)	
				self # return for command chaining
    end # assert_pre_conditions

    def assert_post_conditions(message = '')
      message += "In assert_post_conditions, self=#{inspect}"
			assert_operator(0, :<, GenericTypeRepo::Generic_type_repo.all.size, GenericTypeRepo::Generic_type_repo.all.inspect)
				self # return for command chaining
    end # assert_post_conditions
		
		def assert_no_generalize_cycle(previous_generalizations = [])
      message = "In assert_no_generalize_cycle, self=#{inspect}"
			assert_pre_conditions(message + "\nin assert_pre_conditions")
			previous_generalizations.each {|g| g.assert_pre_conditions}
			if most_general? # recursion termination condition
				previous_generalizations
			else
				generalized_generic_type = Generic_type_repo.by_name(@generalize)
				assert_instance_of(GenericType, generalized_generic_type, inspect + "\n" + generalize.inspect + ' not in ' + GenericType.all.map(&:name).map(&:to_s).join(', '))
				one_more_recursion = (previous_generalizations + [generalized_generic_type]).uniq
				if generalized_generic_type.most_general?
#					puts "generalized_generic_type.most_general? = "  + generalized_generic_type.most_general?.inspect
					return one_more_recursion # terminate 
				else
#					puts 'generalized_generic_type.generalize =' + generalized_generic_type.generalize.inspect
#					puts "generalize = " + generalize.inspect
					if previous_generalizations.map(&:name).include?(@generalize.to_sym)
						message = "\n" + 'There is a cycle in the generalizations for ' + inspect
						message += "\n" + 'previous_generalizations = ' + previous_generalizations.map(&:name).map(&:to_s).join(', ')
						message += "\n" + 'reverse engiuneering previous call'
						message += "\n" + 'one_more_recursion = ' + previous_generalizations.map(&:name).map(&:to_s).join(', ')
#						message += "\n" + 'generalized_generic_type = ' + self.map(&:name).map(&:to_s).join(', ')
#						message += "\n" + 'self = ' + self.map(&:name).map(&:to_s).join(', ')
						raise message
						previous_generalizations
					else
						message = "\n" + 'There is a cycle in the generalizations for ' + inspect
						message += "\n" + 'one_more_recursion = ' + one_more_recursion.map(&:name).map(&:to_s).join(', ')
#						raise message
						generalized_generic_type.assert_no_generalize_cycle(one_more_recursion)
					end #if
					end # if
				end # if
#			self # return for command chaining
		end # assert_no_generalize_cycle
  end # Assertions
  include Assertions
  extend Assertions::ClassMethods
	
#  self.assert_pre_conditions
end # GenericTypeRepo
	
