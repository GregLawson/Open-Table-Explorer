class StreamPattern < ActiveRecord::Base
include Generic_Table
has_many :stream_pattern_arguments
end
