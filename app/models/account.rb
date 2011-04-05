class Account < ActiveRecord::Base
has_many :transfers
include Generic_Table
def logical_primary_key
	return name
end #def
end
