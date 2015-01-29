###########################################################################
#    Copyright (C) 2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
class MatchData
def parse
	if nil? then
    []
	elsif names==[] then
		self[1..-1] # return unnamed subexpressions
	else
#     named_captures for captures.size > names.size
		named_hash={}
		names.each do |n| # return named subexpressions
			named_hash[n.to_sym]=self[n]
		end # each
		named_hash
	end #if
end #parse
end #MatchData
