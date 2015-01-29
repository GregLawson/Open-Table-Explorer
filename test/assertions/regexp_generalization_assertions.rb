###########################################################################
#    Copyright (C) 2010-2012 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
module RegexpGeneralizationAssertions #file context
include Test::Unit::Assertions
require 'rails/test_help'
#include Squeeze_Display
# Assertions (validations)
module ClassMethods
def RegexpMatch.assert_match_array(regexp, string, message=nil)
	 string.instance_of?(Enumeration)
end #assert_match_array
def assert_mergeable(string1, string2)
	regexp=string1.to_exact_regexp
	RegexpMatch.explain_assert_match(regexp, string2)
# now try the reverse
	regexp=string2.to_exact_regexp
	RegexpMatch.explain_assert_match(regexp, string1)
end #assert_mergeable
def assert_regexp_match(regexp_match=self)
	assert_respond_to(regexp_match,:matchedTreeArray)
	assert_not_nil(regexp_match.matchedTreeArray)
	assert_operator(regexp_match.matchedTreeArray.size,:>,0)
	assert_respond_to(regexp_match,:matchedTreeArray)
	assert_not_nil(regexp_match.matchSubTree)
	assert_operator(regexp_match.matchSubTree.size,:>,0)
end #def
end #ClassMethods

end #RegexpGeneralizationAssertions