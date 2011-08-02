class Url < ActiveRecord::Base
include Generic_Table
belongs_to :parameters
def logical_primary_key
	return :url
end
end
