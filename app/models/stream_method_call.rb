class StreamMethodCall < ActiveRecord::Base # like a method call
include Generic_Table
belongs_to :stream_method
has_many :stream_parameters
end #class
