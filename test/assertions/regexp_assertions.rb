###########################################################################
#    Copyright (C) 2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../../app/models/regexp.rb'
class Regexp
require_relative '../../test/assertions.rb'
module Assertions
module ClassMethods
def assert_post_conditions
end #assert_post_conditions
def assert_pre_conditions
end #assert_pre_conditions
end #ClassMethods
def assert_named_captures
	assert_operator(names.size, :>=, 1, named_captures.inspect)
	assert_operator(named_captures.size, :>=, 1, named_captures.inspect)
	assert_equal(names, named_captures.keys)
	all_indices = named_captures.values.flatten.sort
	assert_equal((1..all_indices.size).to_a, all_indices)
end # assert_named_captures
def assert_pre_conditions
# by definition 	assert_match(Regexp.new(Regexp.escape(str), str)
#	assert_equal(self, Regexp.promote(self))
#	assert_equal(self, /#{self.unescaped_string}/)
#	assert_equal(self, Regexp.promote(self).unescaped_string)
end #assert_pre_conditions
def assert_post_conditions
end #assert_post_conditions
def assert_no_exception(message)
end # assert_no_exception
end #Assertions
include Assertions
extend Assertions::ClassMethods
module Examples
include Constants
Ip_number_pattern=/\d{1,3}/
Escape_string='\d'
Back_reference=((/[aeiou]/.capture(:vowel)*/./).back_reference(:vowel)*/./).back_reference(:vowel)
Regexp_exception = Regexp.regexp_error('[')
end #Examples
end #Regexp
