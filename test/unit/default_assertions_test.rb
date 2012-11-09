###########################################################################
#    Copyright (C) 2012 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
module DefaultAssertionTests
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
def test_case_names?
	self.methods(true).select do |m|
		m.match(/^test_/) 
	end #map
end #test_case_names?
def test_CLASS_assert_invariant
	assert(false, "force all tests (explicit and default) to show themselves. tests=#{test_case_names?}")
end #def assert_CLASS_invariant
def test_CLASS_assert_pre_conditions
	assert_include(class_variables, :@@model_class)
	@@model_class=UnboundedFixnum
	assert_include(class_variables, :@@model_class)
	assert_equal(UnboundedFixnumAssertionsTest, self)
	assert_equal(self.name, 'UnboundedFixnumAssertionsTest')
	assert_equal(self.name[-4..-1], 'Test')
	model_class?.assert_pre_conditions
	model_class?.assert_invariant
end #assert_CLASS_pre_conditions
def test_CLASS_assert_post_conditions
	model_class?.assert_post_conditions
end #assert_CLASS_post_conditions
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
