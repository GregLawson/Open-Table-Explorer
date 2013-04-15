###########################################################################
#    Copyright (C) 2011-2012 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
class StreamPatternArgument < ActiveRecord::Base
include Generic_Table
belongs_to :stream_pattern
#has_many :stream_method_arguments # don't know how to link sensibly
def self.logical_primary_key
	return [:stream_pattern_id, :name]
end #logical_key
end
