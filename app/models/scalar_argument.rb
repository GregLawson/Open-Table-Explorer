class ScalarArgument  < ActiveRecord::Base # like a scalar argument 
include Generic_Table
has_many :stream_parameters, :as => :arguments
end #class