###########################################################################
#    Copyright (C) 2011 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
class StreamParameter < ActiveRecord::Base # like the parameters of a method call
include Generic_Table
belongs_to :stream_method_calls
belongs_to :stream_method_arguments
has_many :stream_links
has_many :specifications
def self.logical_primary_key
	return [:stream_method_call_id, :stream_method_argument_id]
end #logical_primary_key
end #class
