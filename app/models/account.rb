class Account < ActiveRecord::Base
has_many :transfers
include Global
def logical_primary_key
	return name
end #def
end
