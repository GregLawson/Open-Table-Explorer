###########################################################################
#    Copyright (C) 2010-2012 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'unbounded_range.rb'
require_relative 'nested_array.rb'
# parse tree internal format is nested Arrays.
# Postfix operators and brackets end embeddded arrays
class RegexpParse
attr_reader :regexp_string,:tokenIndex,:parse_tree
Default_options=Regexp::EXTENDED | Regexp::MULTILINE
OpeningBrackets='({['
ClosingBrackets=')}]'
PostfixOperators='+*?|'
def initialize(regexp_string)
	@tokenIndex=-1 # start at end
	if regexp_string.kind_of?(RegexpParse) then
		@parse_tree=NestedArray.new(regexp_string.parse_tree)
		@regexp_string=regexp_string.to_s	
	elsif regexp_string.kind_of?(Array) then
		@parse_tree=NestedArray.new(regexp_string)
		@regexp_string=regexp_string.join	
	elsif regexp_string.kind_of?(String) then
		@regexp_string=regexp_string
		restartParse!
		@parse_tree=regexpTree!
	elsif regexp_string.kind_of?(Regexp) then
		@regexp_string=regexp_string.source
		restartParse!
		@parse_tree=regexpTree!
	else # unexpected
		raise "unexpected type regexp_string=#{regexp_string} of type #{regexp_string.class.name}"
	
	end #if
	@parse_tree=@parse_tree.merge_single_element_arrays?
end #initialize
def inspect
	"@regexp_string=\"#{@regexp_string}\", @parse_tree=#{@parse_tree.inspect}, @tokenIndex=#{@tokenIndex.inspect}"
end #inspect
def ==(rhs)
	if self.parse_tree==rhs.parse_tree then
		return true
	else
		return false
	end #if
end #equal_operator
def eql?(rhs)
	if self.parse_tree==rhs.parse_tree then
		return true
	else
		return false
	end #if
end #equal
def <=>(rhs)
	if self.parse_tree==rhs.parse_tree then
		return 0
	else
		return nil
	end #if
end #compare
def RegexpParse.promotable?(node)
	if node.instance_of?(Regexp) then 
		true
	elsif node.instance_of?(String) then 
		true
	elsif node.kind_of?(Array) then #nested Arrays
		true
	elsif node.kind_of?(RegexpParse) then #nested Arrays
		false
	elsif node.instance_of?(RegexpParse) then 
		false
	else
		false
	end #if
end #RegexpParse.promotable
def RegexpParse.promote(node)
	if RegexpParse.promotable?(node) then
		RegexpParse.new(node)
	elsif node.kind_of?(RegexpParse) then #nested Arrays
		node
	elsif node.instance_of?(RegexpParse) then 
		node
	elsif node.instance_of?(Regexp) then 
		RegexpParse.new(node.source)
	else
		raise "unexpected node=#{node.inspect}"
	end #if
end #RegexpParse.promote
def to_a
	return @parse_tree
end #to_a
def to_s
	return to_a.join
end #to_s
def postfix_expression?(branch=self)
	branch=RegexpParse.promote(branch)
	postfix_operator=RegexpParse.postfix_operator?(branch.parse_tree[-1])
	if postfix_operator then
		return postfix_operator
	else
		return nil #not postfix chars
	end #if
end #postfix_expression
def RegexpParse.bracket_operator?(branch)
	if branch.kind_of?(RegexpParse) && branch.parse_tree[-1]=='}' then
		return branch.parse_tree 
	elsif branch.kind_of?(String) && branch=='}' then
		return branch 
	else
		return nil	
	end #if
end #bracket_operator
# returns node such as ['*'] or ["{", "3", ",", "4", "}"]
def RegexpParse.postfix_operator?(branch)
	if branch.instance_of?(String) then
		PostfixOperators.index(branch)	
	else
		RegexpParse.bracket_operator?(branch)
	end #if
end #postfix_operator
def postfix_operator_walk(&visit_proc)
	# recurse on subtrees first so transformations ripple up generally
	# postfix expresion should not change operator
	branching=RegexpParse.new(parse_tree.map do |sub_tree|
		if sub_tree.kind_of?(Array) then
			RegexpParse.new(sub_tree).postfix_operator_walk(&visit_proc)
		else # leaf string
			sub_tree
		end #if
	end) #map and RegexpParse.new
#OK	raise "Unexpected #{self.inspect}.postfix_expression?=#{postfix_expression?} != #{branching.inspect}.postfix_expression?=#{RegexpParse.new(branching).postfix_expression?}"  unless postfix_expression? == RegexpParse.new(branching).postfix_expression?
	if postfix_expression? then #postfixes trickle up
		new_branching=visit_proc.call(branching)
			
	else
		new_branching=branching
	end
	return new_branching
end #postfix_operator_walk
def macro_call?(macro=parse_tree)
	return false if '[' != macro[0]
	return false if ']' != macro[-1]
	inner_colons=macro[1..-2] # not another nested array
	return false if ':' != inner_colons[0]
	return false if ':' != inner_colons[-1]
	return	inner_colons[1..-2].join
end #macro_call?
def RegexpParse.operator_range(postfix_operator)
	if postfix_operator=='' then
		return UnboundedRange.new(1, 1)
	elsif postfix_operator=='*' then
		return UnboundedRange.new(0, nil)
	elsif postfix_operator=='+' then
		return UnboundedRange.new(1, nil)
	elsif postfix_operator=='?' then
		return UnboundedRange.new(0, 1)
	else
		raise "unexpected postfix_operator=#{node}"
	end #if
end #operator_range
def repetition_length(node=self)
	node=RegexpParse.promote(node)
	if !node.kind_of?(RegexpParse) then
		return RegexpParse.operator_range(postfix_operator)
	elsif post_op=node.postfix_expression? then
		if post_op=='*' then
			return UnboundedRange.new(0, nil)
		elsif post_op=='+' then
			return UnboundedRange.new(1, nil)
		elsif post_op=='?' then
			return UnboundedRange.new(0, 1)
		else
			raise "unexpected post_op=#{post_op}"
		end #if
	elsif node.parse_tree[-1]=='}' then
		UnboundedRange.new(node.parse_tree[1][0].to_i, node.parse_tree[1][1].to_i)
	else
		UnboundedRange.new(node.parse_tree.length, node.parse_tree.length)
	end #if
end #repetition_length
# Returns a NestedArray object
def repeated_pattern(node=self)
	node=RegexpParse.promote(node)
#	if node.instance_of?(RegexpParse) then
#		node=node.parse_tree
#	else

#		node=RegexpParse.promote(node)
#	end #if	
	if node.postfix_expression? then # argument is not an Array
		return [node.parse_tree[0]]
#	elsif post_op=postfix_expression?(node) then
#		return RegexpParse.new(node[0])
#	elsif node[-1]=='}' then
#		node[0]
	else
		parse_tree
	end #if
end #repeated_pattern
# Expect to eventually replace with inheritance
# Or use in parser (or post-parser initialization) to set classes correcly.
# Need more uniform subclasses
# Is there a useful hierarchy?
def case?(branch=self)
	if branch.instance_of?(String) then
		String # commonly termination condition
	elsif postfix_expression? then
		if alternatives? then
			:Alternatives
		else
			RepetitionLength
		end #if
	else #sequence
		anchoring=RegexpSequence.new(branch)
		if anchoring[:start_anchor].nil? && anchoring[:end_anchor].nil? then unachored sequence
			RegexpParse
		else # anchored
			Anchoring
		end #if
	end #if
end #case
# Private methods that alter state end in !
#private
def restartParse! # primarily for testing
	if @regexp_string.nil? then
		@tokenIndex=-1 # start at end
	else
		@tokenIndex=@regexp_string.length-1 # start at end
	end #if
	@parse_tree=NestedArray.new([])
end #restartParse
def nextToken!
	if beyondString? then
		raise RuntimeError, "method nextToken! called after end of regexp_string."
	elsif @tokenIndex>1 && @regexp_string[@tokenIndex-1..@tokenIndex-1]=='\\' then
		ret='\\'+@regexp_string[@tokenIndex..@tokenIndex]
		@tokenIndex=@tokenIndex-2
	else
		ret=@regexp_string[@tokenIndex..@tokenIndex]
		@tokenIndex=@tokenIndex-1
	end
	return ret
end #nextToken!
def rest
	if beyondString? then
		return ''
	else
		return @regexp_string[0..@tokenIndex]
	end #if
end #rest
def advanceToken!(increment)
	@tokenIndex=@tokenIndex+increment
end #advanceToken!
# test if parsing has gone beyond end of string and should stop
def beyondString?(testPos=@tokenIndex)
	@regexp_string.nil? || testPos<0 || testPos>@regexp_string.length-1
end
# handle {2,3}-style specification of repetitions
# not currently used, since numbers are not interpreted
# currently handled identically to parenthesis and square brackets
def curlyTree!(regexp_string)
	remaining=rest
	matchData=/\{(\d*)(,(\d*))?\}/.match(remaining)
	increment=matchData[1].length+matchData[2].length+1
	advanceToken!(increment)
	return ['{',[matchData[1],matchData[2]],'}']
end #curlyTree
# parse matching brackets, postfix operator, or single character
def parseOneTerm!
	ch=nextToken!
	index=ClosingBrackets.index(ch)
	if index then
		return  regexpTree!(OpeningBrackets[index].chr) << ch
	else
		index=PostfixOperators.index(ch)
		if index then
			return  NestedArray.new([parseOneTerm!, ch])
		else
			return ch
		end #if
	end #if
end #parseOneTerm!
def regexpTree!(terminator=nil)
	ret=NestedArray.new([])
	begin
		if !beyondString? then
			term=parseOneTerm!
			ret << term
		else
			return ret.reverse
		end #if
	end until term==terminator
#not recursive	assert_invariant(ret.reverse)
	return ret.reverse
end #regexpTree!

# The following test case constants can be used externally.
# For internal tests use  RegexpParseTest constants.
# Only assert_post_consitions should be used.
module TestCases #  Namespace
Any_binary_char_string='[\000-\377]'
Any_binary_string="#{Any_binary_char_string}*"
Any_binary_char=RegexpParse.new(Any_binary_char_string)
Any_binary_char_parse=RegexpParse.new(Any_binary_char_string)
Any_binary_string_parse=RegexpParse.new(Any_binary_string)
Quantified_operator_array=["{", "3", ",", "4", "}"]
Quantified_operator_string=Quantified_operator_array.join
Quantified_repetition_array=[".", ["{", "3", ",", "4", "}"]]
Quantified_repetition_string=Quantified_repetition_array.join
#Quantified_repetition_parse=RegexpParse.new(Quantified_repetition_string)
Composite_regexp_array=["t", "e", "s", "t", "/",
	  	[["[", "a", "-", "z", "A", "-", "Z", "0", "-", "9", "_", "]"], "*"],
	 	["[", ".", "]"],
	 	"r",
		[["[", "a", "-", "z", "]"], "*"]]
Composite_regexp_string=Composite_regexp_array.join
Composite_regexp_parse=RegexpParse.new(Composite_regexp_string)
Dot_star_array=['.', '*']
Dot_star_string=Dot_star_array.join
Dot_star_parse=RegexpParse.new(Dot_star_string)
Parenthesized_array=['a', ['(', '.', ')']]
Parenthesized_string=Parenthesized_array.join
Parenthesized_parse=RegexpParse.new(Parenthesized_string)	
Sequence_array=['1', '2', '3']
Sequence_string=Sequence_array.join
Sequence_parse=RegexpParse.new(Sequence_string)
Empty_language_array=[]
Empty_language_string=Empty_language_array.join
Empty_language_parse=RegexpParse.new(Empty_language_string)
module Parameters
Start_anchor_string='^' #should be \S or start of String
End_anchor_string='$' #should be \s or end of String
Anchor_root_test_case='a'
end # module Parameters
No_anchor=RegexpParse.new(Parameters::Anchor_root_test_case)
Start_anchor=RegexpParse.new(Parameters::Start_anchor_string+Parameters::Anchor_root_test_case)
End_anchor=RegexpParse.new(Parameters::Anchor_root_test_case+Parameters::End_anchor_string)
Both_anchor=RegexpParse.new(Parameters::Start_anchor_string+Parameters::Anchor_root_test_case+Parameters::End_anchor_string)
def self.value_of?(name, form)
	constant_reference=constant_reference?(name, form)
	
	if defined? constant_reference then
		constant_reference.constantize
	else
		nil
	end#

end #value_of
def self.constant_reference?(name, form)
	'RegexpParse::TestCases::'+name.to_s+'_'+form.to_s
end #constant_reference
def self.parse_of?(string)
	return RegexpParse.new(string.to_s)
end #parse_of
def self.string_of?(name)
	return array.to_a.join
end #string_of
def self.array_of?(string)
	return parse_of?(string.to_s).to_a
end #array_of
def self.name_of?(constant)
	match=/([A-Z][a-z_]*)_(array|string|parse)$/.match(constant)
	return match
end #name_of
def self.names
	constants=RegexpParse::TestCases.constants
	constants.map do |name|
		constant=('RegexpParse::TestCases::'+name).constantize
		constant=('RegexpParse::TestCases::'+name).constantize
		match=RegexpParse::TestCases.name_of?(name)
		if !match.nil? && (constant.class==String || constant.class==Array || constant.class==RegexpParse) then
			match[1]
		else
			nil
		end #if
	end.compact.uniq #map
end #names
def self.strings
	return RegexpParse::TestCases.constants.select {|c| /.*_string/.match(c)}
end #strings
def self.arrays
	return RegexpParse::TestCases.constants.select {|c| /.*_array/.match(c)}
end #arrays
def self.parses
	return RegexpParse::TestCases.constants.select {|c| /.*_parse/.match(c)}
end #parses
end #TestCases
end #RegexpParse
