class Url < ActiveRecord::Base
include Generic_Table
has_many :stream_methods
def logical_primary_key
	return :url
end #logical_primary_key
def Url.find_by_name(name)
	Url.find_by_href(name)
end #
end #Url
