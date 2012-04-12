###########################################################################
#    Copyright (C) 2010-2012 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
# There is a rails method that does this; forgot name
module Test::Unit::Assertions
def default_message
	message="Module.nesting=#{Module.nesting.inspect}"
	message+=" Class #{self.class.name}"
	message+=" unknown method"
	message+=" self=#{self.inspect}"
	message+=" local_variables=#{local_variables.inspect}"
	message+=" instance_variables=#{instance_variables.inspect}"
	message+=" callers=#{callers}"
	return message
end #default_message
end #Test::Unit::Assertions
module RegexpTreeAssertions
# Assertions (validations)
include Test::Unit::Assertions
require 'rails/test_help'
module ClassMethods
end #ClassMethods
def assert_anchoring
	anchoring=Anchoring.new(self)
#	explain_assert_respond_to(anchoring, :default_message)
#	explain_assert_respond_to(Test::Unit::Assertions, :default_message)
#	message=anchoring.default_message
	message=""
	assert_include(anchoring.start_base, [0,1])
	assert_include(anchoring.end_base, [-1,-2])
	assert_not_empty(self[0..-1])
	assert_not_empty(self[anchoring.start_base..anchoring.end_base])
	assert_not_empty(anchoring[:base_regexp], message)
	assert_equal([anchoring[:start_anchor], anchoring[:base_regexp], anchoring[:end_anchor]].compact.to_s, self.to_s, message)
end #anchor
def assert_specialized_repetitions(other)
	if !other.kind_of?(RegexpTree) then
		other=RegexpTree.new(other)
	end #if
	assert_kind_of(RegexpTree, self)
	assert_kind_of(RegexpTree, other)
	message="In assert_specialized_repetitions, self=#{self.inspect} is not more specialized than (other=#{other.inspect})"
	my_repeated_pattern=self.repeated_pattern
	other_repeated_pattern=other.repeated_pattern
	assert_equal(my_repeated_pattern, other_repeated_pattern)
	my_repetition_length=self.repetition_length
	other_repetition_length=other.repetition_length
	assert_not_nil(my_repetition_length)
	assert_not_nil(other_repetition_length)
	assert_not_nil(my_repetition_length[:min])
	assert_not_nil(other_repetition_length[:min])
	assert_not_equal(my_repetition_length, other_repetition_length)
	assert_operator(my_repetition_length[:min], :<=, other_repetition_length[:max])
	if !my_repetition_length[:max].nil? then
		if other_repetition_length[:max].nil?
			raise message
		else
			assert(my_repetition_length[:max]>=other_repetition_length[:max])
		end #if
	end #if
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
end #compare_character_class
def assert_anchors_specialized_by(other)
	other=RegexpTree.canonical_regexp_tree(other)
	assert_operator(Anchoring.new(self), :>, Anchoring.new(other))
end #compare_anchors
def assert_sequence_specialized_by(other)
	assert_kind_of(Array, self)
	assert_kind_of(Array, other)
	self.each_with_index do |node, i|
		if i-1 <= other.length then
			comparison=node <=> other[i]
			assert_not_nil(comparison, "comparison of #{node.inspect} to #{other[i]} should not be nil.")
			assert_operator(comparison, :>=, 0)
		end #if
	end #each
	assert_equal(1, compare_sequence?(other))
end #sequence_comparison
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
