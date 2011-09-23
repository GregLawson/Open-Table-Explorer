class Url < ActiveRecord::Base
include Generic_Table
has_many :stream_methods
def logical_primary_key
	return :url
end
end
