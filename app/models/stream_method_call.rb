###########################################################################
#    Copyright (C) 2011 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
class StreamMethodCall < ActiveRecord::Base # like a method call
include Generic_Table
belongs_to :stream_method
has_many :stream_links
def StreamMethodCall.schedule
	StreamMethodCall.find(:all).each do |c|
		c.fire
	end #each
end #def
def StreamMethodCall.next_fire
	StreamMethodCall.next
end #def
def fire
	inputs=stream_links.where('input_stream_method_argument_id=?',:id => self.id)
	inputs.each do |input|
		input.fire
	end #each
	stream_method.fire
	outputs=stream_links.find_by_direction('output')
	outputs.fire
end #fire
end #class
