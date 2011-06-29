class StreamMethodCall < ActiveRecord::Base # like a method call
has_one :stream_method
has_many :stream_parameters
end #class
