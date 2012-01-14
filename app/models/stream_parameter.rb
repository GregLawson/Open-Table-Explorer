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
end #class
