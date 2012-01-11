class ExampleType < ActiveRecord::Base
include Generic_Table
require 'test/assertions/ruby_assertions.rb'
belongs_to :generic_type
#def generic_type
#	GenericType.find_by_import_class(self[:generic_type])
#end #generic_type
def valid_context?
	valid? && valid?(:generalize) && valid?(:specialize)
end #valid_context
def valid?(association=nil)
	gt=which_generic_type(association)
	if gt.is_a?(Array) then #specialize
		gt.all? do |g|
			data_regexp=g[:data_regexp]
			Regexp.new(data_regexp).match(self[:example_string])
		end #all
	else
		data_regexp=gt[:data_regexp]
		Regexp.new(data_regexp).match(self[:example_string])
	end #if
end #valid
def which_generic_type(association=nil)
	return case association
	when nil
		generic_type
	when :generalize
		generic_type.generalize
	when :specialize
		generic_type.specialize
	else
		raise "Unexpected value for association=#{association.inspect}"
	end #case
end #which_generic_type

end #ExampleType
