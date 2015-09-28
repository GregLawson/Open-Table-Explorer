###########################################################################
#    Copyright (C) 2011-2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../../app/models/no_db.rb'
require_relative '../../app/models/generic_table.rb' # in test_helper?
require_relative '../../app/models/stream_method.rb' # in test_helper?
class StreamMethodArgument < ActiveRecord::Base # like the arguments of a methed def
include Generic_Table
extend GenericTableAssociation::ClassMethods
belongs_to :stream_method
has_many :stream_links
def initialize(name=nil, direction=nil)
	super() # apply ActiveRecord magic
	self[:name]=name
	self[:direction]=direction
	
end #initialize
def self.logical_primary_key
	return [:stream_method_id, :name]
end #logical_key
def gui_name
	return "@#{self.name}"
end #gui_name
def instance_name_reference
	return "self[:#{self.name}]"
end #instance_name_reference
module Examples
First_stream_argument=StreamMethodArgument.first
end #Examples
include Examples
#require_relative '../../test/assertions/default_assertions.rb'
#require_relative '../../app/models/assertions.rb'
module Assertions
include DefaultAssertions
module ClassMethods
include DefaultAssertions::ClassMethods
def assert_pre_conditions
	StreamMethodArgument.all.map do |u|
	end #map
#	fail "end of class assert_pre_conditions "
end #assert_pre_conditions
def assert_post_conditions
	StreamMethodArgument.all do |sma|
		sma.assert_post_conditions
	end #all
#	fail "end of instance assert_pre_conditions"
end #assert_post_conditions
def assert_invariant
	assert(global_name?(:StreamMethodArgument))
	assert_scope_path(:StreamMethodArgument)
	assert_path_to_constant(:Generic_Table)
#	fail "end of instance assert_pre_conditions"
end #assert_invariant
end #ClassMethods
# true at all times
def assert_invariant
	assert_instance_of(StreamMethodArgument, self)
	assert(!self.class.sequential_id?, "self.class=#{self.class}, should not be a sequential_id.")
	refute_empty(name, inspect)
	refute_empty(self[:name], inspect)
	refute_empty(self['name'], inspect)
	refute_empty(direction, inspect)
	assert_empty(self[:catfish], inspect)
	assert_includes(['Input', 'Output'], direction)
end #assert_invariant
# true after creating an object from scratch
def assert_pre_conditions
#	fail "end of instance assert_pre_conditions"
end #assert_pre_conditions
# conditions after all ActiveRecord reading and initialization 
def assert_post_conditions
	refute_nil(stream_method, inspect)
	assert_constant_path_respond_to(:Generic_Table, :stream_method)
	assert_constant_instance_respond_to(:Generic_Table, :association_state)

	assert_constant_path_respond_to(:StreamMethodArgument, :stream_method)
	assert_constant_path_respond_to(:StreamMethodArgument, :association_state)
	assert_constant_path_respond_to(:GenericTableAssociation, :association_state)
	assert_constant_path_respond_to(:GenericTableAssociation, :ClassMethods, :association_state)
	assert_constant_instance_respond_to(:StreamMethodArgument, :First_stream_argument, :association_state)
	assert_instance_of(StreamMethodArgument, StreamMethodArgument::First_stream_argument)
	assert_includes(StreamMethodArgument::First_stream_argument.public_methods, :association_state, StreamMethodArgument::First_stream_argument.public_methods)
	assert_respond_to(StreamMethodArgument::First_stream_argument, :association_state, StreamMethodArgument::First_stream_argument.methods)
	assert_equal('', StreamMethodArgument::First_stream_argument.association_state(:stream_method))
end #assert_post_conditions
end #Assertions
include Assertions
extend Assertions::ClassMethods
end #StreamMethodArgument
