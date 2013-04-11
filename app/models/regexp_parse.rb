###########################################################################
#    Copyright (C) 2010-2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'unbounded_range.rb'
require_relative 'nested_array.rb'

class RegexpTree < NestedArray
end #RegexpTree
#assert(global_name?(:RexexpTree))

class RegexpToken < RegexpTree
end #RegexpToken
class RegexpSequence < RegexpTree
end #RegexpSequence
class RegexpAlternative < RegexpTree
end #RegexpAlternative
class RegexpRepetition < RegexpSequence
end #RegexpRepetition
class CharacterClass < RegexpAlternative
end #CharacterClass
class RegexpParen < RegexpTree
end #RegexpParen
class RegexpEmpty < RegexpTree
end #RegexpEmpty

# parse tree internal format is nested Arrays.
# Postfix operators and brackets end embeddded arrays
class RegexpParse
attr_reader :regexp_string,:tokenIndex,:parse_tree, :errors
module Constants
OpeningBrackets='({['
ClosingBrackets=')}]'
PostfixOperators='+*?|'
Default_options=Regexp::EXTENDED | Regexp::MULTILINE
end #Constants
include Constants
def initialize(regexp_string, options=Default_options)
	@tokenIndex=-1 # start at end
	if regexp_string.kind_of?(RegexpParse) then
		@parse_tree=NestedArray.new(regexp_string.parse_tree)
		@regexp_string=regexp_string.to_s
		@errors=regexp_string.errors	
	elsif regexp_string.kind_of?(Array) then
		@parse_tree=NestedArray.new(regexp_string)
		@regexp_string=regexp_string.join	
		@errors=RegexpParse.regexp_error(@regexp_string, options)
	elsif regexp_string.kind_of?(String) then
		@regexp_string=regexp_string
		restartParse!
		@parse_tree=regexpTree!
		@errors=RegexpParse.regexp_error(@regexp_string, options)
	elsif regexp_string.kind_of?(Regexp) then
		@regexp_string=regexp_string.source
		restartParse!
		@parse_tree=regexpTree!
		@errors=RegexpParse.regexp_error(@regexp_string, options)
	else # unexpected
		raise "unexpected type regexp_string=#{regexp_string} of type #{regexp_string.class.name}"
	
	end #if
	@parse_tree=@parse_tree.merge_single_element_arrays?
end #initialize
def inspect
	"@regexp_string=\"#{@regexp_string}\", @parse_tree=#{@parse_tree.inspect}, @tokenIndex=#{@tokenIndex.inspect}"
end #inspect
# Rescue bad regexp and return nil
# Example regexp with unbalanced bracketing characters
def RegexpParse.regexp_rescued(regexp_string, options=Default_options)
	raise "expecting regexp_string=#{regexp_string}" unless regexp_string.instance_of?(String)
	return Regexp.new(regexp_string, options)
rescue RegexpError
	return nil
end #regexp_rescued
def RegexpParse.regexp_error(regexp_string, options=Default_options)
	raise "expecting regexp_string=#{regexp_string.inspect}" unless regexp_string.instance_of?(String)
	return Regexp.new(regexp_string, options)
rescue RegexpError => exception
	return exception
end #regexp_error

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
def to_regexp
	return Regexp.new(to_s)
end #to_regexp
# If node has a postfix operator or a bracketed length range
# return postfix operator (what about | operator?)
# else return nil (no repetition) (not {1,1}?)
def RegexpParse.postfix_expression?(node)
	node=RegexpParse.promote(node)
	postfix_operator=RegexpParse.postfix_operator?(node.parse_tree[-1])
	if postfix_operator then
		return postfix_operator
	else
		bracket_operator=RegexpParse.bracket_operator?(node)
		if bracket_operator then
			bracket_operator
		else
			return nil #not postfix chars
		end #if
	end #if
end #postfix_expression
def postfix_expression?
	RegexpParse.postfix_expression?(self)
end #postfix_expression
# detect bracket operator (not postfix characters)
# node is parse tree or string to test (not Regexp)
# unlike postfix expression node, only last node should be passed
# return bracket parse tree - bracket expression detected
# return closing bracket character - closing bracket character
# return nil - no bracket 
def RegexpParse.bracket_operator?(node)
	if node.kind_of?(NestedArray) && node[-1]=='}' then
		return node 
	elsif node.kind_of?(RegexpParse) && node.parse_tree[-1]=='}' then
		return node.parse_tree 
	elsif node.kind_of?(String) && node=='}' then
		return node 
	else
		return nil	
	end #if
end #bracket_operator
# node is parse tree or string to test
# unlike postfix expression node, only last node should be passed
# returns node such as ['*'] or ["{", "3", ",", "4", "}"]
# returns nil if not a postfix operator
def RegexpParse.postfix_operator?(node)
	if node.instance_of?(String) then
		index=PostfixOperators.index(node)	
		if index.nil? then
			nil
		else
			PostfixOperators[index]
		end #if
	else
		RegexpParse.bracket_operator?(node)
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
		return RegexpParse.new([node.parse_tree[0]])
#	elsif post_op=postfix_expression?(node) then
#		return RegexpParse.new(node[0])
#	elsif node[-1]=='}' then
#		node[0]
	else
		self
	end #if
end #repeated_pattern
# Expect to eventually replace with inheritance
# Or use in parser (or post-parser initialization) to set classes correcly.
# Need more uniform subclasses
# Is there a useful hierarchy? Sequence (chars and trees) and alternatives (char class, |)
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
def to_pathname_glob
	ret=RegexpParse.new(parse_tree.map_branches{|b| (b[0]=='('?RegexpTree.new(b[1..-2]):RegexpParse.new(b))})
	ret=ret.postfix_operator_walk{|p| '*'}
	if ret.instance_of?(RegexpParse) then
		ret=ret.parse_tree.flatten.join
	elsif ret.kind_of?(Array) then
		ret=ret.flatten.join
	end #if
	return ret
end #to_pathname_glob
def pathnames
	Dir[to_pathname_glob].select do |pathname|
		to_regexp.match(pathname)
	end #select
end #pathnames
def grep(pattern, delimiter="\n")
	pathnames.files_grep(pattern, delimiter="\n")
end #grep
def RegexpParse.case?(node)
	if node.instance_of?(String) then
		:String # commonly termination condition
	else
		node=RegexpParse.promote(node)
		if postfix_operator=RegexpParse.postfix_expression?(node) then
			:RegexpRepetition
		elsif node.to_a[-1]==']' then
			:CharacterClass
		elsif node.to_a[-1]==')' then
			:RegexpParen
		elsif node==Empty_language_parse then
			:RegexpEmpty
		elsif RegexpParse.postfix_expression?(node.to_a[0]) =='|' then
			:RegexpAlternative
		else #sequence is default
			:RegexpSequence
		end #if
	end #if
end #case
def RegexpParse.typed?(node)
	node=RegexpParse.promote(node)
	type=RegexpParse.case?(node)
	eval(type.to_s).new(node.parse_tree)
end #typed
module Constants
Any_binary_char_string='[\000-\377]'
Any_binary_string="#{Any_binary_char_string}*"
Any_binary_char=RegexpParse.new(Any_binary_char_string)
Any_binary_char_parse=RegexpParse.new(Any_binary_char_string)
Any_binary_string_parse=RegexpParse.new(Any_binary_string)
Dot_star_array=['.', '*']
Dot_star_string=Dot_star_array.join
Dot_star_parse=RegexpParse.new(Dot_star_string)
Empty_language_array=['\A', '\z'] # beginning to end of string with nothing in between
Empty_language_string=Empty_language_array.join
Empty_language_parse=RegexpParse.new(Empty_language_string)
end #Constants
end #RegexpParse
