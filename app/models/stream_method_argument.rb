###########################################################################
#    Copyright (C) 2011 by Greg Lawson                                      
#    <GregLawson@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
class StreamMethodArgument < ActiveRecord::Base # like the arguments of a methed def
include Generic_Table
has_many :stream_methods
#belongs_to :parameter , :polymorphic => true
end #class
