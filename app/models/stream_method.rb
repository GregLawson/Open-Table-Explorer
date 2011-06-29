class StreamMethod  < ActiveRecord::Base # like a method def
has_many :stream_method_calls
has_many :stream_method_arguments, :as => :arguments
end #class
