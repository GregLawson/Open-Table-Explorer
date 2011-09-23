###########################################################################
#    Copyright (C) 2011 by Greg Lawson                                      
#    <GregLawson@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
class StreamMethodCall < ActiveRecord::Base # like a method call
include Generic_Table
belongs_to :stream_method
has_many :stream_parameters
def StreamMethodCall.schedule
	StreamMethodCall.find(:all).each do |c|
		c.fire
	end #each
end #def
def StreamMethodCall.next_fire
	StreamMethodCall.find(:all)
end #def
def fire
	inputs=[]
	inputs.fire
	stream_method.execute
	outputs.fire
end #fire
end #class
