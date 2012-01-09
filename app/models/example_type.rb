class ExampleType < ActiveRecord::Base
include Generic_Table
belongs_to :generic_type
#def generic_type
#	GenericType.find_by_import_class(self[:generic_type])
#end #generic_type
def valid_context?
	valid? && valid?(:generalize) && valid(:specialize)
end #valid_context
def valid?(association=nil)
	generic_type=which_generic_type(association)
	generic_type[:data_regexp].match(self[:example_string])
end #valid
def which_generic_type(association=nil)
	return case association
	when nil
		generic_type
	when :generalize
		generalize.generic_type
	when :specialize
		specialize.generic_type
	else
		raise "Unexpected value for association=#{association}"
	end #case
end #which_generic_type
def assert_generic_type(association=nil, message=nil)
	message=build_message(message, "example_type=?, association=?", self, association.inspect) 
	case association
	when nil
		; # DO NOTHING
	when :generalize, :specialize
		assert_associations(self.class, association, message)
	else
		raise "Unexpected value for association=#{association}"
	end #case
	generic_type=which_generic_type(association)
	assert_not_nil(generic_type, message)
	assert_not_empty(generic_type[:data_regexp])
end #generic_type
def assert_example_type_valid(association=nil, message=nil)
	message=build_message(message, "example_type=?, association=?", self, association.inspect) 
#	assert_not_nil(example_type)
	assert_not_empty(self[:example_string])
	assert_generic_type(association)
	assert(valid?(association))
end #example_type_valid
end #ExampleType
