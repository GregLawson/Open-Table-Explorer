class ExampleType < ActiveRecord::Base
include Generic_Table
belongs_to :generic_type
#def generic_type
#	GenericType.find_by_import_class(self[:generic_type])
#end #generic_type
def valid?
	valid_self? && valid_generalization? && valid_specialization?
end #valid?
def valid_self?(test_string=self[:example_string])
	return Regexp.new(generic_type[:data_regexp]).match(test_string)	
end #valid_self?
def valid_generalization?(test_string=self[:example_string])
	return Regexp.new(generic_type.generalize[:data_regexp]).match(test_string)
end #valid_generalization?
def valid_specialization?(test_string=self[:example_string])
	return generic_type.specialize.all?{|t| Regexp.new(t[:data_regexp]).match(test_string)}
end #valid_specialization?
end #ExampleType
