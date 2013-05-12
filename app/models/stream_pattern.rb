###########################################################################
#    Copyright (C) 2011 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
class StreamPattern < ActiveRecord::Base
include Generic_Table
has_many :stream_pattern_arguments
has_many :stream_methods
#def self.logical_primary_key
#	return [:name]
#end #logical_key
end
