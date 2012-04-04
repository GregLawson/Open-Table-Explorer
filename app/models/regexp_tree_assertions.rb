###########################################################################
#    Copyright (C) 2010-2012 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
# There is a rails method that does this; forgot name
module RegexpTreeAssertions
# Assertions (validations)
include Test::Unit::Assertions
require 'rails/test_help'
module ClassMethods
end #ClassMethods
def assert_specialized_by(specialized)
	if !specialized.kind_of?(RegexpTree) then
		specialized=RegexpTree.new(specialized)
	end #if
	comparison=self <=> specialized
	message "In self=#{self.inspet}assert_specialized_by(specialized=#{specialized.inspect})"
	my_cc=self.character_class?[1..-2]
	other_cc=other.character_class?[1..-2]
	intersection=my_cc & other_cc
	my_repeated_pattern=self.repeated_pattern
	other_repeated_pattern=other.repeated_pattern
	my_repetition_length=self.repetition_length
	other_repetition_length=other.repetition_length
	assert_equal(1, comparison)
	assert_operator(self, :>, specialized, message)
end #assert_specialized_by
end #RegexpMatch
