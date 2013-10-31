###########################################################################
#    Copyright (C) 2010-2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative '../assertions/regexp_match_assertions.rb'
#require '/home/greg/Desktop/git/no_rails/test/assertions/regexp_tree.rb'

class RegexpMatchTest < TestCase #file context
include DefaultTests
include RegexpMatch::Examples
include RegexpMatch::Assertions::ClassMethods
#def test_to_exact_regexp
#	unambiguous_string=%{abc0123}
#	assert_match(Regexp.new(unambiguous_string), unambiguous_string)
#	assert_equal(unambiguous_string, Regexp.new(unambiguous_string).source)
#	assert_match(unambiguous_string.to_exact_regexp, unambiguous_string)
#	ambiguous_string=%{()[]{}.?+*}
#	assert_match(Regexp.new(Regexp.escape(ambiguous_string)), ambiguous_string)
#	assert_equal(Regexp.escape(ambiguous_string), Regexp.new(Regexp.escape(ambiguous_string)).source)
#	assert_match(Regexp.new(Regexp.escape(ambiguous_string)), ambiguous_string)
#	assert_match(ambiguous_string.to_exact_regexp, ambiguous_string)
#end #to_exact_regexp
def test_promote
	assert_instance_of(RegexpMatch, RegexpMatch.promote('a', 'b'))
	assert_equal(Alternative, RegexpMatch.promote('a', 'b'))
	RegexpMatch.new('(', '(').assert_pre_conditions
end #promote
def test_initialize
	Matches.assert_pre_conditions
	Alternative.assert_pre_conditions
	Deletion.assert_pre_conditions
	Insertion.assert_pre_conditions
	White_Match.assert_pre_conditions	

	Keditor.assert_pre_conditions
	Rows_Match.assert_pre_conditions
	RowsEdtor2.assert_pre_conditions
	Addresses.assert_pre_conditions
	RegexpMatch.new('(', '(').assert_pre_conditions

	regexp_match_sequence=RegexpMatch.new([RegexpMatch.new('a','a'), RegexpMatch.new('b', 'b')], 'ac')
#	assert_nil(regexp_match_sequence.matched_data)	
#	assert_equal("[(?mx-i:a) matches 'a', (?mx-i:b) matches 'b']", regexp_match_sequence.regexp_tree, "regexp_match_sequence=#{regexp_match_sequence}")
#regexp_tree
end #initialize
def test_double_equal
	assert(Alternative==RegexpMatch.promote('a', 'b'))
	assert_equal(Alternative, RegexpMatch.promote('a', 'b'))
end #==
def test_inspect
	Matches.assert_pre_conditions
	assert_equal("(?mx-i:a) matches 'a'", Matches.inspect)
	Addresses.assert_pre_conditions
	assert_equal("(?mx-i:<Url:0xb5f22960>) does not match '<Url:0xb5ce4e3c>'", Addresses.inspect)

end #inspect
def test_map_matches
	data_to_match=Addresses.dataToParse
	branch=Addresses
	Addresses.assert_match_branch(branch, data_to_match)
	branch_match=Addresses.match_branch(branch)
	matched_data=branch_match.matched_data
	if matched_data.nil? || matched_data.size==0 then
		if branch.kind_of?(Array) then
			start_match=0
			branch.map do |subTree|
				branch.map_matches(subTree, data_to_match[start_match..-1])
			end #map
		else # no match, not kind of Array
			RegexpMatch.new(branch, data_to_match)
		end #if
	else
		data_to_match=matched_data.post_match
		return branch_match # successful match
	end #if
	assert_not_nil(Addresses.map_matches)
	assert_instance_of(RegexpMatch, Addresses.map_matches)
	assert_equal("<Url:0xb5ce4e3c>", Addresses.map_matches, "Addresses.map_matches=#{Addresses.map_matches.inspect}")
	assert_instance_of(RegexpMatch, Addresses.map_matches[0])
	assert_equal("<Url:0xb5ce4e3c>", Addresses.map_matches.matched_data[0])
end #map_matches
def test_match_branch
	matches=[0..8, 15..15]
	data_to_match=Addresses.dataToParse
	startPos=0
	Addresses.assert_match_branch(Addresses[matches[1]], data_to_match[startPos..-1])
	branch_match=Addresses.match_branch(Addresses[matches[1]], data_to_match[startPos..-1])
	assert_instance_of(RegexpMatch, branch_match)
	message="Addresses[startPos..15]=#{Addresses[startPos..15]}, data_to_match[startPos, -1]=#{data_to_match[startPos, -1]}"
	message+="\nbranch_match=#{branch_match.inspect}"

	assert_equal(">", branch_match.dataToParse, message)
	assert_equal(/>/mx, branch_match.to_regexp, message)
	assert_equal('>', branch_match.dataToParse, message)
	startPos=6
	branch_match=Addresses.match_branch(Addresses[matches[1]], data_to_match[startPos..-1])
	message="Addresses[startPos..15]=#{Addresses[startPos..15]}, data_to_match[startPos, -1]=#{data_to_match[startPos, -1]}"
	assert_equal(">", branch_match.dataToParse, message)
	assert_equal(/>/mx, branch_match.to_regexp, message)
	assert_equal('>', branch_match.dataToParse, message)
#	Addresses.assert_match_branch(Addresses[matches[1]], data_to_match[startPos..-1])
end #match_branch
def test_map_consecutiveMatches
	matches=Addresses.consecutiveMatches(+1,0,0)
	assert_instance_of(Array, matches)
	data_to_match=Addresses.dataToParse
	assert_not_empty(data_to_match)
	startPos=0
	branch_match=Addresses.match_branch(Addresses[matches[1]], data_to_match[startPos, -1])
#	assert_equal({/0/ => nil}, branch_match, "Addresses[startPos..15]=#{Addresses[startPos..15]}, data_to_match[startPos, -1]=#{data_to_match[startPos, -1]}")
	assert_not_empty(data_to_match)
	matched_regexp=matches.map do |m|
		message="m=#{m}, Addresses[m]=#{Addresses[m]}, data_to_match=#{data_to_match}"
		assert_not_empty(data_to_match, message)
		Addresses.assert_match_branch(Addresses[m], data_to_match)
		branch_match=Addresses.match_branch(Addresses[m], data_to_match)
		assert_not_nil(branch_match)
		matched_data=branch_match[:matched_data]
		if matched_data.nil? || matched_data.size==0 then
		else
			assert_not_nil(matched_data, "Addresses[m]=#{Addresses[m]}, data_to_match=#{data_to_match}")
			assert_not_empty(data_to_match, message)
			data_to_match=data_to_match[matched_data.size..-1]
			message2= message+", matched_data=#{matched_data}"
			message2+=", data_to_match[#{matched_data.size}"
#			message2+=", -1]=#{data_to_match[matched_data.size, -1]}"
			assert_not_empty(data_to_match, message2)
		end #if
		assert_not_equal(data_to_match, Addresses.dataToParse)
		branch_match
	end #map
	assert_equal(matched_regexp, Addresses.map_consecutiveMatches(matches))
	assert_equal([{:data_to_match=>"<Url:0xb5ce4e3c>",
		  :regexp=>/<Url:0xb5/,
		  :matched_data=>"<Url:0xb5"},
		{:data_to_match=>"ce4e3c>", :regexp=>/0/, :matched_data=>nil},
 		{:data_to_match=>"ce4e3c>", :regexp=>/>/, :matched_data=>">"}], Addresses.map_consecutiveMatches(matches))
end #map_consecutiveMatches
def test_consecutiveMatches
	assert_empty(Alternative.consecutiveMatches(+1))
	assert_equal(2..2, Deletion.consecutiveMatch(-1, 1, 2))
	assert_equal(2..2, Deletion.consecutiveMatch(+1, 1, 2))
	assert_equal([2..2],Deletion.consecutiveMatches(+1, 1, 2))
	assert_equal([0..0,2..2],Deletion.consecutiveMatches(+1))
	assert_equal([0..0,1..1],Insertion.consecutiveMatches(+1))
	matches=Addresses.consecutiveMatches(+1)
	Addresses.assert_consecutiveMatches(matches)
	regexp_match_array=matches.map{|r| Addresses[r]}
	assert_instance_of(Array, regexp_match_array)
	assert_kind_of(Array, regexp_match_array[matches[0]])
	assert_instance_of(String, Addresses.dataToParse)
	regexp_matches=RegexpMatch.new(regexp_match_array, Addresses.dataToParse)
	message="regexp_matches=#{regexp_matches.inspect}"
	assert_equal([0..8, 15..15], matches, message)
	matched_regexp=matches.map do |m|
		Addresses[m].to_s
	end #map
	assert_equal(['<Url:0xb5', '>'], matched_regexp)

end #consecutiveMatches
def test_consecutiveMatch
	assert_equal(['K','x','C'],Deletion.to_a)
	assert_equal(['K','C'],Insertion.to_a)

	assert_equal(0..0, Deletion.consecutiveMatch(+1))
	assert_nil(Deletion.consecutiveMatch(+1, 1, 1))
	assert_equal(2..2, Deletion.consecutiveMatch(-1))
	assert_equal(0..0, Insertion.consecutiveMatch(+1,0,0))
	assert_equal(2..2, Deletion.consecutiveMatch(-1,0,2))
	assert_nil(Deletion.consecutiveMatch(-1,1,1))
	startPos=2
	endPos=2
	matchData=RegexpMatch.match_data?(Deletion[startPos..endPos], Deletion.dataToParse)
	assert_equal(['C'], Deletion[startPos..endPos])
	assert(matchData)
	assert_equal(2..2,Deletion.consecutiveMatch(-1,2,2))
	assert_equal(2..2,Insertion.consecutiveMatch(-1,2,2))
	match1=Addresses.consecutiveMatch(+1)
	Addresses.assert_consecutiveMatch(match1)
	assert_equal(0..8, match1)
	match2=Addresses.consecutiveMatch(+1,9)
	assert_not_nil(match2)
#	assert_equal(14..14, match2)
	assert_equal(14..14, Addresses.consecutiveMatch(+1,9, 15))
	assert_equal(14..14, Addresses.consecutiveMatch(+1,9))
	assert_not_nil(match1)
	Addresses.assert_consecutiveMatch(match2, match1)
	match3=Addresses.consecutiveMatch(+1,15)
	Addresses.assert_consecutiveMatch(match3, match2)
	assert_equal(15..15, match3)
	Addresses.assert_consecutiveMatch(match3, match2)
	assert_equal(2..2, Deletion.consecutiveMatch(-1, 1, 2))
	assert_no_match(RegexpTree.new(Deletion[1]).to_regexp, Deletion.dataToParse)
	assert_match(RegexpTree.new(Deletion[2..2]).to_regexp, Deletion.dataToParse)
	assert_equal(2..2, Deletion.consecutiveMatch(+1, 2, 2))
	assert_equal(2..2, Deletion.consecutiveMatch(+1, 1, 2))
end #consecutiveMatch
def test_editor
	assert_regexp_match(Deletion)
end #def
def test_zero_parameter_new
	assert_nothing_raised{RegexpTree.new} # 0 arguments
	assert_not_nil(model_class?)
end #test_name_correct
end #test class
