###########################################################################
#    Copyright (C) 2011 by Greg Lawson                                      
#    <GregLawson@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
class StreamLink < ActiveRecord::Base
include Generic_Table
belongs_to :outputs, :class_name => "StreamMethodArgument",
    :foreign_key => "output_stream_method_argument_id"
belongs_to :inputs, :class_name => "StreamMethodArgument",
    :foreign_key => "input_stream_method_argument_id"
belongs_to :store_method, :class_name => "StreamMethod",
	:foreign_key => "store_method_id"
belongs_to :next_method, :class_name => "StreamMethod",
	:foreign_key => "next_method_id"
end
