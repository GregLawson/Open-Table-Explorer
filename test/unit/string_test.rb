###########################################################################
#    Copyright (C) 2010-2012 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'test_helper'
# executed in alphabetical order. Longer names sort later.
# place in order from low to high level and easy pass to harder, so that first fail is likely the cause.
# move passing tests toward end
#require 'test/test_helper_test_tables.rb'
class StringTest < ActiveSupport::TestCase
def test_to_exact_regexp
#	RegexpTree::Binary_bytes.each do |c|
	RegexpTree::Ascii_characters.each do |c|
		assert_not_nil(RegexpTree.regexp_rescued(Regexp.escape(c)), "Invalid regexp for character='#{c.to_exact_regexp}'.")
		assert_equal(Regexp.escape(c), RegexpTree.regexp_rescued(Regexp.escape(c)).source)	
		assert_equal(c.to_exact_regexp, RegexpTree.regexp_rescued(Regexp.escape(c)))
	end #each
end #to_exact_regexp
def test_String_to_a
	assert_equal(['a', 'b', 'c'],'abc'.to_a)
	assert_not_equal(['b', 'b', 'c'],'abc'.to_a)
end #to_a
end #test class
