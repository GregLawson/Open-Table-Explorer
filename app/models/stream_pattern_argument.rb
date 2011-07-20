class StreamPatternArgument < ActiveRecord::Base
include Generic_Table
belongs_to :stream_pattern
end
