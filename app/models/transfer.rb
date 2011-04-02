class Transfer < ActiveRecord::Base
belongs_to :account
include Global
def logical_primary_key
	return id
end #def
end
