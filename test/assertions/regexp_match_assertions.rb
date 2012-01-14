###########################################################################
#    Copyright (C) 2010-2012 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
# There is a rails method that does this; forgot name
module Squeeze_Display
@@Max_Context=100
@@Max_Lines=5
def maxedDisplay(str,maxLength=@@Max_Context)
	if str.length>maxLength then
		return str[0,maxLength]+' ...'
	else
		return str
	end #if	
end #def
def squeezeDisplay(str)
	if str.nil? then
		return 'nil'
	elsif str.empty? then
		return ''
	elsif str.length<2*@@Max_Context then
		return str
	else
		return 'Starts with:'+str[0,@@Max_Context]+'\nand ends with: ... '+str[-@@Max_Context,str.length]
	end
end #def
def matchDisplay(regexp)
	matchData=matchRescued(regexp)
#	assert_instance_of(matchData,MatchData)
	if matchData.nil? then
		# Global::log.info("For /#{regexp}/ no matches.")
	else
		# Global::log.info("regexp=/#{regexp}/ has #{matchData.size} matches.")
		for i in 0..matchData.size-1
			# Global::log.info("matchData[#{i}]=#{squeezeDisplay(matchData[i]).inspect}")
		end
	end
end #def
end #module
class RegexpMatch < RegexpTree
# Assertions (validations)
include Test::Unit::Assertions
require 'rails/test_help'
include Squeeze_Display
include Match_Addressing
def RegexpMatch.explain_assert_match(regexp, string, message=nil)
	message="regexp=#{regexp}, string='#{string}'"
	match_data=regexp.match(string)
	if match_data.nil? then
		regexp_tree=RegexpMatch.new(regexp, string)
		message=message+"regexp_tree.matchSubTree=#{regexp_tree.matchSubTree.inspect}"
	end #if
	assert_match(regexp, string, message)
end #assert_match
def RegexpMatch.assert_match_array(regexp, string, message=nil)
	 string.instance_of?(Enumeration)
end #
end #class