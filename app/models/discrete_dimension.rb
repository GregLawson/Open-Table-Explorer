###########################################################################
#    Copyright (C) 2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
#require_relative '../../app/models/no_db.rb'
class DiscreteDimension < Array
module ClassMethods
end #ClassMethods
extend ClassMethods
module Constants
end #Constants
include Constants
# attr_reader
def initialize(enumerable, start_index=0)
	super(enumerable)
	@index=start_index
end #initializE
def next
	@index=@index+1
	if @index > size then
		raise StopIteration
	else
		self[@index-1] #preincrement value
	end #if
end #next
require_relative '../../test/assertions.rb';module Assertions

module ClassMethods

def assert_pre_conditions(message='')
	message+="In assert_pre_conditions, self=#{inspect}"
end #assert_pre_conditions
def assert_post_conditions(message='')
	message+="In assert_post_conditions, self=#{inspect}"
end #assert_post_conditions
end #ClassMethods
def assert_pre_conditions(message='')
end #assert_pre_conditions
def assert_post_conditions(message='')
end #assert_post_conditions
end #Assertions
include Assertions
extend Assertions::ClassMethods
#self.assert_pre_conditions
module Examples
include Constants
Branches=DiscreteDimension.new([:master, :passed, :testing,:edited])
end #Examples
end #DiscreteDimension
