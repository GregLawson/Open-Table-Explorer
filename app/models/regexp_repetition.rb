###########################################################################
#    Copyright (C) 2010-2012 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
class RepetitionLength < RegexpTree
include Comparable
attr_reader :repeated_pattern,:repetition_length
# RepetitionLength.new(RegexpTree)
# RepetitionLength.new(RegexpTree, UnboundedRange)
# RepetitionLength.new(RegexpTree, min, max)
# Ambiguity of nil for third prameter: missing or infinity?
# Resolved by checking second parameter for numric or Range to resolve ambiguity
def initialize(branch, min=nil, max=nil)
	branch=RepetitionLength.promote(branch)
	if !max.nil? then # all arguments provided
		super(branch.repeated_pattern)
		@repetition_length=UnboundedRange.new(min, max)
		raise "min must not be nil." if min.nil? 
	elsif !min.nil? then # only one length argument
		if min.kind_of?(Range) then
			super(branch.repeated_pattern)
			@repetition_length=min
		else #third parameter specified as nil/infinity
			super(branch.repeated_pattern)
			@repetition_length=UnboundedRange.new(min, max)
			raise "min must not be nil." if min.nil? 
		end #if
	else # implicit length
		super(branch.repeated_pattern)
		@repetition_length=branch.repetition_length
	end #if
end #initialize
def <=>(other)
 	if @begin==other.begin && @end==other.end && self.repeated_pattern==other.repeated_pattern then
		return 0
	elsif @begin<=other.begin && (@end.nil? || @end>=other.end) then
		return 1
	elsif other.begin<=@begin && (other.end.nil? || other.end>=@end) then
		return -1
	else
		return nil
	end #if
end #compare
# calculate sum for merging sequential repetitions
def +(other)
	if @end.nil? || other.end.nil? then
		max=nil # infinity+ anything == infinity
	else
		max=@end+other.end
	end #if
	return RepetitionLength.new(@begin+other.begin, max)
end #plus
# intersection. If neither is a subset of the other return nil 
def &(other)
	min= [@begin, other.begin].max
	max=if @end.nil? then
		other.end
	else
		case @end <=> other.end
		when 1,0
			other.end
		when -1
			@end
		when nil
			return nil	
		end #case
	end #if
	RepetitionLength.new(min, max)
end #intersect
# Union. Unlike set union disjoint sets return a spanning set.
def |(other)
	min= [@begin, other.begin].min
	max=if @end.nil? then
		nil
	else
		case @end <=> other.end
		when 1,0
			@end
		when -1
			other.end
		when nil
			max=[@end, ther.end].max	
		end #case
	end #if
	RepetitionLength.new(min, max)
end #union / generalization
# the useful inverse function of new. String to regexp
def self.canonical_regexp(regexp)
	if regexp.instance_of?(String) then
		regexp=RegexpTree.regexp_rescued(regexp)
	elsif regexp.instance_of?(Array) || regexp.instance_of?(RegexpTree) || regexp.instance_of?(RegexpMatch) then
		regexp=RegexpTree.regexp_rescued(regexp.to_s)
	elsif regexp.nil? then
		return //
	elsif !regexp.instance_of?(Regexp) then
		raise "Unexpected regexp.class=#{regexp.class}."
	end #if
	return regexp
end #canonical_regexp
def self.canonical_regexp_tree(regexp)
	if regexp.instance_of?(String) then
		regexp=RegexpTree.new(regexp)
	elsif regexp.instance_of?(Array) || regexp.instance_of?(RegexpTree) || regexp.instance_of?(RegexpMatch) then
		regexp=RegexpTree.new(regexp.to_s)
	elsif regexp.nil? then
		return //
	elsif !regexp.instance_of?(Regexp) then
		raise "Unexpected regexp.class=#{regexp.class}."
	end #if
	return regexp
end #canonical_regexp_tree
def canonical_repetition_tree(min=@begin, max=@end)
	return RegexpTree.new(['{', [min.to_s, ',', max.to_s], '}'])
end #canonical_repetition_tree
# Return a RegexpTree node for self
# Concise means to use abbreviations like '*', '+', ''
# rather than the canonical {n,m}
# If no repetition returns '' equivalent to {1,1}
def concise_repetition_node(min=@begin, max=@end)
	if min==0 then
		if max==1 then
			return '?'
		elsif max.nil? then
			return '*'
		else
			return canonical_repetition_tree(min, max)
		end #if
	elsif min==1 then
		if max==1 then
			return ''
		elsif max.nil? then
			return '+'
		else
			return canonical_repetition_tree(min, max)
		end #if
	elsif min==max then
		return RegexpTree.new(['{', [min.to_s], '}'])
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
# to 1 for certain match like /.*/ (actually Any is more accurate)
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
end #RepetitionLength
