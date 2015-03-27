###########################################################################
#    Copyright (C) 2010-2014 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'regexp_parser'
require_relative 'stream_tree.rb'
require_relative 'regexp.rb'
module RegexpParseType
extend Connectivity::ClassMethods
module ClassMethods
def RegexpParseType.children?(node)
		children_if_exist?(node, :expressions)
end # children
def expression_class_symbol?(node)
	node.class.name[20..-1].to_sym # should be magic-number-free
end # expression_class_symbol?
end #ClassMethods
extend Connectivity::ClassMethods
extend ClassMethods
module Examples
include Connectivity::Examples
Node_format = proc do |e|
	"#{RegexpParseType.expression_class_symbol?(e).to_s}(:#{e.type}, :#{e.token}, '#{e.text}')"
end # Node_format
Mx_format = proc do |e, depth, terminal|
	ret = ' ' * depth + e.node.text + ' # '
	ret + Tree_node_format.call(e, depth, terminal)
end # Mx_format
Mx_dump_format = proc do |e, depth, terminal|
	ret = ' ' * depth + e.node.text + ' # '
	ret + e.node.inspect
end # Mx_dump_format
end # Examples
include Examples
module ClassMethods
def inspect_node(node, &inspect_proc)
	if !block_given? then # default node inspection
		inspect_proc = RegexpParseType::Examples::Node_format

	end # if
	inspect_proc.call(node)
end # inspect_node
def inspect_recursive(node, &inspect_proc)
	if !block_given? then
		inspect_proc = Tree_node_format
	end # if
	super(node, &inspect_proc)
end # inspect_recursive
end #ClassMethods
extend ClassMethods
end # RegexpParseType

class Regexp
class Expression::Base
include Tree
module Constants
end # Constants
include Constants
def raw_capture?(string)
	RegexpParseType.map_recursive(self) do |e, depth, terminal|
		sub_regexp = Regexp.new(e.to_s)
		if e.node.quantifier then
			unquantified_regexp = e.node.to_s[0, -1-e.node.quantifier.to_s.size]
			unquantified_regexp = Regexp.new(e.to_s[0..-1-e.node.quantifier.to_s.size])
			{:parse => e, :raw_capture=> LimitCapture.new(string, unquantified_regexp)}
		else
			{:parse => e, :raw_capture=> MatchCapture.new(string, sub_regexp)}
		end # if
	end # map_recursive
end # raw_capture?
module Examples
include Constants
Children_method_name = :expressions
Literal_a = Regexp::Parser.parse( /a*/.to_s, 'ruby/1.8')
Children_a = Literal_a.send(Children_method_name)
Son_a = Children_a[0]
Grandchildren_a = Son_a.expressions
Grandson_a = Grandchildren_a[0]
Node_a = "Literal(:literal, :literal, 'a')"
Inspect_node_root = "Root(:expression, :root, '')"
Node_options = "Group::Options(:group, :options, '(?-mix:')"
Tree_node_root = "nonterminal[0], " + Inspect_node_root
Tree_node_options = "nonterminal[1], " + Node_options
Tree_node_a = "leaf typed[2], " + Node_a
Grandson_a_map =	Tree_node_a
Son_a_map =	[Tree_node_options, [Grandson_a_map]]
Literal_a_map = [Tree_node_root, [Son_a_map]]
Mx_node_root = ' # ' + Tree_node_root
Mx_node_options = ' (?-mix: # ' + Tree_node_options
Mx_node_a = '  a # ' + Tree_node_a
Sequence_example = Regexp::Parser.parse(/ab/.to_s, 'ruby/1.8')
Alternative_example = Regexp::Parser.parse(/a|b/.to_s, 'ruby/1.8')
end # Examples
include Examples
end # Expression
end # Regexp
def to_pathname_glob
	map {|node| node.to_pathname_glob}
end #to_pathname_glob
def to_pathname_glob
	if any? {|node| node.size>1} then
		'*'
	else
		'['+join(',')+']'
	end #if
end #to_pathname_glob

# parse tree internal format is nested Arrays.
# Postfix operators and brackets end embeddded arrays
class RegexpParse
include Regexp::Constants
module Constants
include Regexp::Constants
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
