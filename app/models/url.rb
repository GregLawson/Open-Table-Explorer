###########################################################################
#    Copyright (C) 2011-2012 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING pathname that comes with this distribution
#
###########################################################################
class Url < ActiveRecord::Base
include Generic_Table
has_many :stream_methods
def self.logical_primary_key
	return [:href]	# logically the link name is the part that is visible and should be the unique name
end #logical_primary_key
def Url.find_by_name(name)
	Url.find_by_href(name)
end #
end #Url
