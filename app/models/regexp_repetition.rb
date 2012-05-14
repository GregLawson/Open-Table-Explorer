###########################################################################
#    Copyright (C) 2010-2012 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
class RegexpRepetition < RegexpTree
include Comparable
attr_reader :repeated_pattern,:repetition_length
# RegexpRepetition.new(RegexpTree)
# RegexpRepetition.new(RegexpTree, UnboundedRange)
# RegexpRepetition.new(RegexpTree, min, max)
# Ambiguity of nil for third prameter: missing or infinity?
# Resolved by checking second parameter for numric or Range to resolve ambiguity
def initialize(branch, min=nil, max=nil, probability_space_regexp='[[:print:]]+', options=Default_options)
	branch=RegexpRepetition.promote(branch)
	@repeated_pattern=branch.repeated_pattern
	if !max.nil? then # all arguments provided
		@repetition_length=UnboundedRange.new(min, max)
		raise "min must not be nil." if min.nil? 
	elsif !min.nil? then # only one length argument
		if min.kind_of?(Range) then
			@repetition_length=min
		else #third parameter specified as nil/infinity
			@repetition_length=UnboundedRange.new(min, max)
			raise "min must not be nil." if min.nil? 
		end #if
	else # implicit length
		@repetition_length=branch.repetition_length
	end #if
end #initialize
Any=RegexpRepetition.new(RegexpTree::Any_binary_string, nil, nil, RegexpTree::Any_binary_string)
Many=RegexpRepetition.new(".+", nil, nil, ".+")
Dot_star=RegexpRepetition.new(['.','*'], nil, nil, RegexpTree::Any_binary_string)

def <=>(rhs)
	lhs=self
 	base_compare=lhs.repeated_pattern <=> rhs.repeated_pattern
 	length_compare=lhs.repetition_length <=> rhs.repetition_length
	return base_compare.nonzero? || length_compare
end #compare
# intersection. If neither is a subset of the rhs return nil 
def &(rhs)
	lhs=self
 	base=lhs.repeated_pattern & rhs.repeated_pattern
 	length=lhs.repetition_length & rhs.repetition_length
	return RegexpRepetition.new(base, length)
end #intersect
# Union. Unlike set union disjoint sets return a spanning set.
def |(rhs)
	lhs=self
 	base=lhs.repeated_pattern | rhs.repeated_pattern
 	length=lhs.repetition_length | rhs.repetition_length
	return RegexpRepetition.new(base, length)
end #union / generalization
# the useful inverse function of new. String to regexp
def canonical_repetition_tree(min=self.repetition_length.begin, max=self.repetition_length.end)
	return RegexpTree.new(['{', [min.to_s, ',', max.to_s], '}'])
end #canonical_repetition_tree
# Return a RegexpTree node for self
# Concise means to use abbreviations like '*', '+', ''
# rather than the canonical {n,m}
# If no repetition returns '' equivalent to {1,1}
def concise_repetition_node(min=self.repetition_length.begin, max=self.repetition_length.end)
	if min.to_i==0 then
		if max.to_i==1 then
			return '?'
		elsif max==UnboundedFixnum::Inf then
			return '*'
		else
			return canonical_repetition_tree(min, max)
		end #if
	elsif min.to_i==1 then
		if max==1 then
			return ''
		elsif max==UnboundedFixnum::Inf then
			return '+'
		else
			return canonical_repetition_tree(min, max)
		end #if
	elsif min==max then
		return RegexpTree.new(['{', [min.to_i.to_s], '}'])
	else
		return canonical_repetition_tree(min, max)
	end #if
	return RegexpTree.new(['{', [min.to_s, max.to_s], '}'])
end #concise_repetition_node
# Probability range depending on matched length
def probability_range(node=self)
	if node.instance_of?(String) then
		range=node.size..node.size
	else
		range=node.repetition_length
	end #if
	return probability_of_repetition(range.begin)..probability_of_repetition(range.end)
end #probability_range
# Probability for a single matched repetitions of an alternative (single character)
# Here the probability distribution is 
# assumed uniform across the probability space
# ranges from zero for an impossible match (usually avoided)
# to 1 for certain match like /.*/ (actually RegexpRepetition::Any is more accurate)
# returns nil if indeterminate (e.g. nested repetitions)
# (call probability_range or RegexpMatch#probability instead)
# match_length (of random characters) is useful in unanchored cases
# match_length.nil? 
# probability (.p) of length n
# I == L & R
# then L >= I && R >= I
# and L.p(n) >= I.p(n) && R.p(n) >= I.p(n)
def probability_of_repetition(repetition, match_length=nil, branch=self)
	if branch.instance_of?(String) then
		alternatives=1
		base=branch
		repetition_length=branch.repetition_length
		anchoring=Anchoring.new(branch)
	else
		repetition_length=branch.repetition_length
		base=branch.repeated_pattern
		anchoring=Anchoring.new(branch)
		alternative_list=alternatives?(branch.repeated_pattern) # kludge for now
		if alternative_list.nil? then
			return nil
		else
			alternatives=alternative_list.size
		end  #if
	end #if
	character_probability=alternatives.to_f/probability_space_size
	if repetition==0 then
		probability=1.0
	elsif repetition.nil? then # infinit repetition
		if character_probability==1.0 then
			probability=1.0
		else
			probability=0.0
		end #if
	else
		probability=character_probability**repetition
	end #if
	raise "probability_space_regexp=#{probability_space_regexp} is probably too restrictive for branch=#{branch.inspect}" if probability>1.0
	return probability
end #probability_of_repetition
# recursive merging of consecutive identical pairs
def merge_to_repetition(branch=self)
	if branch.instance_of?(Array) then
		branch=RegexpTree.new(branch)
	end #if
	if branch.size<2 then # terminate recursion
		return branch
	else
# puts "branch=#{branch}"
		first=branch[0]
		second=branch[1]
		if branch.repeated_pattern(first)==branch.repeated_pattern(second) then
			first_repetition=first.repetition_length
			second_repetition=branch.repetition_length(second)
			merged_repetition=(first_repetition+second_repetition).concise_repetition_node
			merge_to_repetition(first.repeated_pattern << merged_repetition+branch[2..-1])
		else # couldn't merge first element
			[first]+merge_to_repetition(branch[1..-1])	# shorten string to ensure recursion termination
		end #if
	end #if
end #merge_to_repetition
end #RegexpRepetition
