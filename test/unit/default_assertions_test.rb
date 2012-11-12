###########################################################################
#    Copyright (C) 2012 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
module DefaultAssertionTests
# methods to extract model, class from TestCase subclass
def name_of_test?
	self.class.name
end #name_of_test?
# Extract model name from test name if Rails-like naming convention is followed
def model_name?
	name_of_test?.sub(/Test$/, '').sub(/Assertions$/, '')
end #model_name?
def table_name?
	model_name?.tableize
end #table_name?
def model_class?
	eval(model_name?)
end #model_class?
def names_of_tests?
	self.methods(true).select do |m|
		m.match(/^test_/) 
	end #map
end #names_of_tests?
def test_Class_assert_invariant
	assert_equal(self.class.name[-4..-1], 'Test')
	assert_equal(6, names_of_tests?.size, "#{names_of_tests?.sort}")
end # assert_invariant
def test_Class_assert_pre_conditions
	model_class?.assert_pre_conditions
end #assert_Class_pre_conditions
def test_Class_assert_post_conditions
	model_class?::TestCases.constants_by_class(model_class?).each do |c|
		c.assert_pre_conditions
	end #each
	model_class?.assert_post_conditions
end #assert_Class_post_conditions
def test_assert_pre_conditions
	self.class::Example.assert_pre_conditions

end #assert_pre_conditions
def test_assert_invariant
	self.class::Example.assert_invariant
end #def assert_invariant
def test_assert_post_conditions
	self.class::Example.assert_post_conditions
end #assert_post_conditions
end #DefaultAssertionTests
