###########################################################################
#    Copyright (C) 2010-2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
# parse tree internal format is nested Arrays.
require_relative '../../app/models/regexp_tree.rb'
#class RegexpTree < NestedArray # declare class
#end #RegexpTree reopen later
# Postfix operators and brackets end embeddded arrays
class Anchoring #< ActiveSupport::HashWithIndifferentAccess
include Comparable
attr_reader :start_base, :end_base
def initialize(regexp_tree)
	@start_base=0
	@end_base=-1
	self[:start_anchor]=if regexp_tree[0]=='^' then
		@start_base=1
		'^'
	else
		nil
	end #if
	self[:end_anchor]=if regexp_tree[-1]=='$' then
		@end_base=-2
		'$'
	else
		nil
	end #if
	self[:base_regexp]=regexp_tree[@start_base..@end_base]
end #initialize
def compare_anchor(other, key)
	if self[key]==other[key] then
		return 0
	elsif other[key] then 
		return 1
	elsif self[key] then 
		return -1
	else
		return nil
	end #if
end #compare_anchor
def <=>(other)
	comparison_case=[compare_anchor(other, :start_anchor), compare_anchor(other, :end_anchor)]
	case comparison_case
	when [0,0]
		return 0
	when [0,1], [1,1], [1,0] #specialized and equal
		return 1
	when [0,-1], [-1,-1] #specialized and equal
		return -1
	when [-1,1], [1,-1] #disagreement
		nil
	else
		raise "In Anchoring.<=> Unexpected case=#{comparison_case.inspect},self=#{self.inspect}, other=#{other.inspect}"
	end #case
end #<=>
end #Anchoring
class RegexpSequence < RegexpTree
include Comparable
module Constants
class StartString <RegexpTree; end
class EndString <RegexpTree; end
class StartLine <RegexpTree; end
class EndLine <RegexpTree; end
end #Constants
# Parse regexp_string into parse tree for editing
def initialize(*nodes)
	nodes.each do |node|
		node=RegexpTree.promote(node)
		self.append(node)
	end #map
end #initialize
def RegexpTree.promote(node)
	if node.kind_of?(RegexpTree) then #nested Arrays
		node
	elsif node.kind_of?(Array) then #nested Arrays
		RegexpSequence.new(node)
		
	elsif node.instance_of?(String) then 
		RegexpSequence.new(RegexpParse.new(node).to_a)
	elsif node.instance_of?(RegexpParse) then 
		RegexpSequence.new(node.to_a)
	elsif node.instance_of?(Regexp) then 
		RegexpSequence.new(RegexpParse.new(node.source).to_a)
	else
		raise "unexpected node=#{node.inspect}"
	end #if
end #RegexpTree.promote
# branch must be a RegexpTree sequence
def probability_of_sequence(branch=self)
	raise "probability_of_sequence branch=#{branch.inspect} must be a kind of Array" unless branch.kind_of?(Array)
	branch.unanchor.reduce(1) do |product, element| 
		if element.instance_of?(String) then
			product * probability_of_repetition(1, 1, element) 
		elsif element.kind_of?(Array) then
			product * probability_of_sequence(RegexpSequence.new(element)) 
		else
			product * probability_of_repetition(element.repetition_length, 1, element.repeated_pattern) 
		end #if
	end #reduce
end #probability_of_sequence
def compare_anchors?(other)
	if self.to_s == other.to_s then
		return 0
	else
		Anchoring.new(self) <=> Anchoring.new(other)
	end #if
end #anchoring
def unanchor(branch=self)
	Anchoring.new(self)[:base_regexp]
end #unanchor
def start_anchor(branch=self)
	RegexpSequence.new(['^', Anchoring.new(self)[:base_regexp]])
end #start_anchor
def end_anchor(branch=self)
	RegexpSequence.new([Anchoring.new(self)[:base_regexp], '$'])
end #end_anchor
def exact_anchor(branch=self)
	RegexpSequence.new(['^', Anchoring.new(self)[:base_regexp], '$'])
end #exact_anchor
def compare_sequence?(other)
	return nil if other.instance_of?(String)
	if self.length==1 || other.length==1 then
		comparison=self[0] <=> other[0]
		if self.length > other.length then
			return -1
		elsif self.length == other.length then
			return comparison
		else
			return 1
		end #if
	else
		comparison=self[0] <=> other[0]
		comparison1=self[1..-1] <=> other[1..-1]
		if comparison.nil? || comparison1.nil? then
			return nil # part incomparable
		else case [comparison, comparison1]
		when [0,0]
			0
		when [1,1], [0,1], [1,0]
			1
		when [-1,-1], [0,-1], [-1,0]
			-1
		when  [1,-1], [-1,1]
			nil
		else
			raise "bad case"
		end #case
		end #if
	end #if
end #sequence_comparison
# if there is no intersection return Empty_language
Empty_language=RegexpSequence.new([])
def sequence_intersect(rhs)
	if rhs.instance_of?(String) then
		if alternatives?.include(rhs) then
			return rhs	
		else
			Empty_language
		end #if
	elsif rhs[0].instance_of?(String) then
		if alternatives?.include(rhs[0]) then
			return rhs[0]	
		else
			Empty_language
		end #if
	elsif self.size==1 || rhs.size==1 then
		self[0].alternatives_intersect(rhs[0])			
	elsif alternatives?.nil? then
		Empty_language
	elsif alternatives?.empty? then
		Empty_language
	else
		first=self[0].alternatives_intersect(rhs[0])
		RegexpSequence.new([first, self[1..-1].alternatives_intersect(rhs[1..-1])])
	end #if
end #sequence_intersect
# intersetion should be interpreted as
# the intersection of the Languages (sets of possible matches)
# that can be matched by each regexp
# I == L & R
# then L >= I && R >= I
# if no intersetion: I==[]
# then L >= [] and R >= []
def +(other)
	return RegexpSequence.new(self.to_a+other.to_a)
end #+
module Examples
include Constants
Sequence=RegexpSequence.new(['1', '2', '3'])
A=RegexpSequence.new('a')
B=RegexpSequence.new('b')
Ab=RegexpSequence.new('ab')
end #Examples
end #RegexpTree
