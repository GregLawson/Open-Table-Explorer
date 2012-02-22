class Measurement < ActiveRecord::Base
include Generic_Table
belongs_to :load
def self.logical_primary_key
	return [:id]
end #logical_primary_key
end #Measurement
