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
URL_name='URL'
URL_argument=StreamMethodArgument.find_all_by_name(URL_name)
First_URL_argument=URL_argument.first
end #Examples
include Examples
require_relative '../../test/assertions/default_assertions.rb'
module Assertions
include DefaultAssertions
module ClassMethods
include DefaultAssertions::ClassMethods
def assert_pre_conditions
	StreamMethodArgument.all.map do |u|
	end #map
#	fail "end of class assert_pre_conditions "
end #assert_pre_conditions
end #ClassMethods
# true at all times
def assert_invariant
	assert_instance_of(StreamMethodArgument, self)
	assert(!self.class.sequential_id?, "self.class=#{self.class}, should not be a sequential_id.")
	assert_not_empty(name, inspect)
	assert_not_empty(self[:name], inspect)
	assert_not_empty(self['name'], inspect)
	assert_not_empty(direction, inspect)
	assert_empty(self[:catfish], inspect)
end #assert_invariant
# true after creating an object from scratch
def assert_pre_conditions
#	fail "end of instance assert_pre_conditions"
end #assert_pre_conditions
# conditions after all ActiveRecord reading and initialization 
def assert_post_conditions
	assert_include(['Input', 'Output'], direction)
	assert_not_nil(stream_method, inspect)
	assert(global_name?(:StreamMethodArgument))
	assert_constant_path_respond_to(:Generic_Table, :stream_method)
	assert_scope_path(:StreamMethodArgument)
	assert_constant_path_respond_to(:Generic_Table)
	assert_constant_instance_respond_to(:Generic_Table)

	assert_constant_path_respond_to(:StreamMethodArgument, :stream_method)
	assert_constant_path_respond_to(:stream_method)
	assert_equal('', association_state(:stream_method))
	assert_path_to_constant(:Generic_Table)
end #assert_post_conditions
end #Assertions
include Assertions
extend Assertions::ClassMethods
end #StreamMethodArgument
