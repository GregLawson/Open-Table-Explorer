class ScalarArgument  < ActiveRecord::Base # like a scalar argument 
has_many :stream_parameters, :as => :arguments
end #class