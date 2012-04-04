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
def assert_specialized_repetitions(other)
	if !other.kind_of?(RegexpTree) then
		other=RegexpTree.new(other)
	end #if
	assert_kind_of(RegexpTree, self)
	assert_kind_of(RegexpTree, other)
	message="In self=#{self.inspect}assert_other_by(other=#{other.inspect})"
	my_repeated_pattern=self.repeated_pattern
	other_repeated_pattern=other.repeated_pattern
	assert_equal(my_repeated_pattern, other_repeated_pattern)
	my_repetition_length=self.repetition_length
	other_repetition_length=other.repetition_length
	assert_not_equal(my_repetition_length, other_repetition_length)
	assert(my_repetition_length[0]<=other_repetition_length[0])
	assert(my_repetition_length[1]>=other_repetition_length[1])
	assert(my_repetition_length[0]<=other_repetition_length[0] &&  my_repetition_length[1]>=other_repetition_length[1])
end #compare_repetitions
def assert_specialized_character_class(specialized)
	if !specialized.kind_of?(RegexpTree) then
		specialized=RegexpTree.new(specialized)
	end #if
	assert_kind_of(RegexpTree, self)
	assert_kind_of(RegexpTree, specialized)
	message="In self=#{self.inspect}assert_specialized_by(specialized=#{specialized.inspect})"
	my_cc=self.character_class?
	assert_not_nil(my_cc)
	my_chars=my_cc[1..-2]
	specialized_cc=specialized.character_class?
	assert_not_nil(specialized_cc)
	specialized_chars=specialized_cc[1..-2]
	intersection=my_chars & specialized_chars
	assert_equal(intersection, specialized_chars)
end #assert_specialized_character_class
def assert_specialized_by(specialized)
	if !specialized.kind_of?(RegexpTree) then
		specialized=RegexpTree.new(specialized)
	end #if
	assert_kind_of(RegexpTree, self)
	assert_kind_of(RegexpTree, specialized)
	message="In self=#{self.inspect}assert_specialized_by(specialized=#{specialized.inspect})"
	my_cc=self.character_class?
	specialized_cc=specialized.character_class?
	if !my_cc.nil? && !specialized_cc.nil? then
		assert_specialized_character_class(specialized_cc)
	end #if
	message="In self=#{self.inspect}assert_specialized_by(specialized=#{specialized.inspect})"
	my_cc=self.character_class?
	specialized_cc=specialized.character_class?
	if !my_cc.nil? && !specialized_cc.nil? then
		assert_specialized_character_class(specialized_cc)
	end #if
	my_repeated_pattern=self.repeated_pattern
	specialized_repeated_pattern=specialized.repeated_pattern
	if my_repeated_pattern==specialized_repeated_pattern then
		assert_specialized_repetitions(other)
	end #if
	comparison=self <=> specialized
	assert_equal(1, comparison)
	assert_operator(self, :>, specialized, message)
end #<=>
end #RegexpTree
