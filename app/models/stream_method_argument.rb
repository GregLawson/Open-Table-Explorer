###########################################################################
#    Copyright (C) 2011-2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../../app/models/no_db.rb'
require_relative '../../app/models/generic_table.rb' # in test_helper?
class StreamMethodArgument < ActiveRecord::Base # like the arguments of a methed def
include Generic_Table
belongs_to :stream_method
has_many :stream_links
def initialize(name, direction)
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
def assert_pre_conditions
	assert_instance_of(StreamMethodArgument, self)
#	fail "end of instance assert_pre_conditions"
end #assert_pre_conditions
end #Assertions
include Assertions
extend Assertions::ClassMethods
end #StreamMethodArgument
