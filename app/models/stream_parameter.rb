class StreamParameter < ActiveRecord::Base # like the parameters of a method call
include Generic_Table
belongs_to :stream_method_calls
belongs_to :stream_method_arguments
end #class