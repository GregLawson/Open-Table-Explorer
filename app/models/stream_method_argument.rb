###########################################################################
#    Copyright (C) 2011 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
class StreamMethodArgument < ActiveRecord::Base # like the arguments of a methed def
include Generic_Table
belongs_to :stream_method
has_many :stream_links
end #class
