class GenericType < ActiveRecord::Base
include Generic_Table
has_many :example_Types, :foreign_key => "import_class",
	:conditions => "import_class = 'Timestamp_Column'"
def example_types
	return ExampleType.find_all_by_import_class(self[:import_class])
end #example_types
def parent
	Generic_Table.where("search_sequence > ? ", self[:search_sequence])
  
end #parent
end #GenericType
