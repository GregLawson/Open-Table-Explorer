class TableSpec < ActiveRecord::Base
has_many :acquisition_stream_specs
belongs_to :frequency
include Global
def logical_primary_key
	return :model_class_name
end #def

end
