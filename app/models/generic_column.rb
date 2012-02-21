class GenericColumn < ActiveRecord::Base
include Generic_Table
def logical_primary_key
	return [:model_class, :column_name]
end #logical_primary_key
end
