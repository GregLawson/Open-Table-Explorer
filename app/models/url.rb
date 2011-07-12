class Url < ActiveRecord::Base
include Generic_Table
def logical_primary_key
	return :url
end
end
