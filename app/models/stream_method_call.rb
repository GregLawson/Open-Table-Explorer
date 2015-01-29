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
has_many :stream_parameters
has_many :stream_links
def self.logical_primary_key
	return [:id]
end #logical_primary_key
def StreamMethodCall.find_by_name(name)
	StreamMethodCall.find_by_stream_method(name)
end #find_by_name
def StreamMethodCall.acquisitions
	acquisition_pattern=StreamPattern.find_by_name('Acquisition')
	StreamMethod.find_by_pattern map do |m|
			c.fire
	end #map
end #acquisitions
def StreamMethodCall.next_fire
	if @@fired.nil? then
		
	else
	end #if
	StreamMethodCall.next
end #def
def inputs
	stream_links.where(:input_stream_method_argument_id => self.id, :direction => 'input')
	
end #inputs
def outputs
	stream_links.where('output_stream_method_argument_id=?',:id => self.id).find_by_direction('output')
	
end #outputs
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
