###########################################################################
#    Copyright (C) 2012-2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
module DefaultAssertions
require 'test/unit'
include Test::Unit::Assertions
module ClassMethods
include Test::Unit::Assertions
# conditions that are always true (at least atomically)
def assert_invariant
	assert_instance_of(Class, self)
end # class_assert_invariant
# conditions true while class is being defined
# assertions true after class (and nested module Examples) is defined
def assert_pre_conditions
end #class_assert_pre_conditions
# assertions true after class (and nested module Examples) is defined
def assert_post_conditions
	self.example_constant_names_by_class(self).each do |c|
		c.assert_pre_conditions
	end #each
end #class_assert_post_conditions
def value_of_example?(name)
	const_get(name.to_s)
end #value_of_example
def example_constant_names_by_class(klass=self, regexp=//)
	constants.map do |constant_symbol|
		value=value_of_example?(constant_symbol)
		if value.instance_of?(klass) then
			if constant_symbol.to_s.match(regexp) then
				constant_symbol
			else
				nil
			end #if
		else
			nil
		end #if
	end.compact #select
end #example_constant_names_by_class
def example_constant_values_by_class(klass=self, regexp=//)
	constants.map do |constant_symbol|
		value=value_of_example?(constant_symbol)
		if value.instance_of?(klass) then
			if constant_symbol.to_s.match(regexp) then
				value
			else
				nil
			end #if
		else
			nil
		end #if
	end.compact #select
end #example_constant_values_by_class
end #ClassMethods
def assert_pre_conditions
end #assert_pre_conditions
# Instance methods
def assert_invariant

end #def assert_invariant

# Post conditions are true after an operation
def assert_post_conditions
end #assert_post_conditions
end #DefaultAssertions

