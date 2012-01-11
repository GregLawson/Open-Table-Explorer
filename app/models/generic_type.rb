class GenericType < ActiveRecord::Base
include Generic_Table
has_many :example_types
has_many :specialize, :class_name => "GenericType",
    :foreign_key => "generalize_id"
belongs_to :generalize, :class_name => "GenericType",
    :foreign_key => "generalize_id"

#def example_types
#	return ExampleType.find_all_by_generic_type(self[:generic_type])
#end #example_types
def ancestors(candidates=GenericType.all)
	
	candidates.select {|c| c.example_types.all?{|e| e.valid_parent?(e[:example_string])}}
end #ancestors
#def generalize
#	return GenericType.find(self[:generalize])
#end #generalize
def descendants(candidates=GenericType.all)
	candidates.select {|c| c.example_types.all?{|e| !e.valid_parent?(e[:example_string])}}
  
end #descendants
end #GenericType
