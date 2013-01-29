###########################################################################
#    Copyright (C) 2010-2012 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../../app/models/regexp_parse.rb'
require_relative '../../test/assertions/ruby_assertions.rb'
# parse tree internal format is nested Arrays.
# Postfix operators and brackets end embeddded arrays
class RegexpParse
require_relative '../assertions/default_assertions.rb'
require 'test/unit'
module Assertions
include Test::Unit::Assertions
extend Test::Unit::Assertions
module ClassMethods
include Test::Unit::Assertions
def assert_invariant
	assert_equal(RegexpParse, self)
	assert_include(instance_methods(false), :parseOneTerm!)
	assert_include(instance_methods(true), :assert_post_conditions)
	assert_include(instance_methods(true), :assert_repetition_range)
#	moduleName='RegexpParse::Examples'
	moduleName='RegexpParse'
	klass=RegexpParse
	message="Module #{moduleName} not included in #{RegexpParse.inspect} context.Modules actually included=#{klass.ancestors.inspect}."
	assert(RegexpParse.module_included?(moduleName), message)
	assert_module_included(RegexpParse, RegexpParse)
	message2= "klass.module_included?(moduleName)=#{klass.module_included?(moduleName)}"
#	Restartable_parse.restartParse!
#	assert_equal(Restartable_parse.regexpTree!,['K'])
#	KC_parse.restartParse!
#	assert_equal(['K','C'],KC_parse.regexpTree!)
#	assert_equal(["(", "<", "t", "r", [".", "*"], "<", "/", "t", "r", ">"],Rows_parse.regexpTree!('('))
end #assert_class_invariant_conditions
# conditions true after initialization of class constants.
# pre-conditions of constants should now be true
def assert_post_conditions
	assert_invariant
	assert_operator(Examples.parses.size, :>, 0)
	Examples.parses.each do |parse|
		parse.assert_pre_conditions
	end #each
end #assert_class_post_conditions
# assert conversions to arrays and strings are correct and reversable (?).
def assert_round_trip(array)
	assert_equal(array, ::RegexpParse.new(array).parse_tree)
	assert_equal(array.to_s, RegexpParse.new(array.to_s).to_s)
	assert_equal(Regexp.new(array.to_s).source, RegexpParse.new(Regexp.new(array.to_s)).to_s)
end #assert_round_trip
end #ClassMethods
# invariant assertions that can be called during parsing for debugging parsing functions.
def assert_invariant
	message="assert_invariant: regexp_string=#{@regexp_string},rest=#{rest},parse_tree.inspect=#{@parse_tree.inspect}."
	assert_equal(NestedArray, @parse_tree.class)
	assert_not_nil(regexp_string, message)
	assert_not_nil(parse_tree, message)
	assert_not_nil(tokenIndex, message)
	assert_instance_of(String, rest)
	assert_instance_of(String, @regexp_string)
	assert_instance_of(NestedArray, @parse_tree)
	assert_equal(@regexp_string, rest+@parse_tree.to_s, message)
	self.class.assert_pre_conditions
end #assert_invariant
# assertions during object initialization (RegexpParse.new) or after restart parse!
def assert_pre_conditions(parser=self)
	assert_invariant
	message="parser=#{parser.inspect}"
	assert_equal(@regexp_string.length-1, parser.tokenIndex, message)
	assert(!parser.beyondString?)
	assert(parser.rest.length>0)
	assert(parser.rest==parser.regexp_string)
	
end #assert_pre_conditions
# Post conditions are true after an operation
# assert that an initialized RegexpParse instance is valid and fully parse
def assert_post_conditions(parser=self)
	assert_invariant
	message="parser=#{parser.inspect}"
	if parser.tokenIndex== -1 then
		assert_equal(-1, parser.tokenIndex, message)
		assert(parser.rest=='')
		assert(parser.beyondString?)
	else # not fully parse
		message="Not fully parse. In internal tests call only if you are sure parsing is complete. Another test may have restarted the parsing."
		assert_equal(-1, parser.tokenIndex, message)
		
	end #if
end #assert_post_conditions
# should this be an assertion or merged with above?
def regexpParserTest(parser)
#	Now test after full parse.
	parser.restartParse!
	parser.assert_pre_conditions
#	Test after a little parsing.
	assert_not_nil(parser.nextToken!)
	assert(parser.rest!=parser.regexp_string)
	
	parser.restartParse!
	assert_not_nil(parser.parseOneTerm!)
	
	parser.restartParse!
	assert(parser.parseOneTerm!.size>0)

#	Now test after full parse.
	parser.restartParse!
	assert_not_nil(parser.regexpTree!)
	
	parser.restartParse!
	parser.assert_invariant	
	parser.restartParse!
	assert(parser.regexpTree!.size>0)
end #regexpParserTest
def assert_repetition_range(range)
	assert_post_conditions
	range.assert_unbounded_range_equal(repetition_length)
	assert_operator(range.first, :>=, 0)
	assert_operator(repetition_length.first, :>=, 0)
end #assert_repetition_range
def assert_postfix_expression
	post_op=postfix_expression?
	assert_not_nil(post_op,"self=#{self.inspect}")
end #postfix_expression
def self.value_of?(name, form)
	constant_reference=constant_reference?(name, form)
	
	if defined? constant_reference then
		RegexpParse::TestCases.const_get(name.to_s+'_'+form.to_s)
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
# removes suffix if present else nil
def self.name_of?(constant)
	match=/([A-Z][a-z_]*)_(array|string|parse)$/.match(constant)
	return match
end #name_of
def self.names
	constants=RegexpParse::TestCases.constants
	constants.map do |name|
		constant=RegexpParse::TestCases.const_get(name)
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
end #Assertions
include Assertions
extend Assertions::ClassMethods
include DefaultAssertions
extend DefaultAssertions::ClassMethods
module Examples #  Namespace
include Constants
Asymmetrical_Tree_Parse=RegexpParse.new(NestedArray::Examples::Asymmetrical_Tree_Array)
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
Parenthesized_array=['a', ['(', '.', ')']]
Parenthesized_string=Parenthesized_array.join
Parenthesized_parse=RegexpParse.new(Parenthesized_string)	
Sequence_array=['1', '2', '3']
Sequence_string=Sequence_array.join
Sequence_parse=RegexpParse.new(Sequence_string)
module Parameters
Start_anchor_string='^' #should be \S or start of String
End_anchor_string='$' #should be \s or end of String
Anchor_root_test_case='a'
end # module Parameters
No_anchor=RegexpParse.new(Parameters::Anchor_root_test_case)
Start_anchor=RegexpParse.new(Parameters::Start_anchor_string+Parameters::Anchor_root_test_case)
End_anchor=RegexpParse.new(Parameters::Anchor_root_test_case+Parameters::End_anchor_string)
Both_anchor=RegexpParse.new(Parameters::Start_anchor_string+Parameters::Anchor_root_test_case+Parameters::End_anchor_string)
CONSTANT_PARSE_TREE=RegexpParse.new('K')
Restartable_parse=CONSTANT_PARSE_TREE.clone
#CONSTANT_PARSE_TREE.freeze

KC_parse=RegexpParse.new('KC')
RowsRegexp='(<tr.*</tr>)'
Rows_parse=RegexpParse.new(RowsRegexp)
RowsEdtor2=RegexpParse.new('\s*(<tr.*</tr>)')
KCET_parse=RegexpParse.new('KCET[^
]*</tr>\s*(<tr.*</tr>).*KVIE')
def path_array?(name, suffix='')
	path_array=[:RegexpParse, :Examples, (name.to_s+suffix.to_s).to_sym]
end #path_array
def full_name?(name, suffix='')
	full_name='RegexpParse::Examples::'+name.to_s+suffix.to_s
	ret=begin
		eval(full_name.to_s)
		full_name
	rescue 
		nil
	end #begin
end #full_name
end #Examples
include Examples
end #RegexpParse
