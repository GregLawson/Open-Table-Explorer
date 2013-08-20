###########################################################################
#    Copyright (C) 2010-2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
class Regexp
#include Comparable
module ClassMethods
def promote(node)
	if node.instance_of?(String) then 
		Regexp.new(Regexp.new(Regexp.escape(node)))
	elsif node.instance_of?(Regexp) then 
		node
	else
		raise "unexpected node=#{node.inspect}"
	end #if
end #promote
end #ClassMethods
extend ClassMethods
def *(other)
	return Regexp.new(self.to_s+Regexp.promote(other).to_s)
end #*
def |(other)
	return Regexp.union(self, Regexp.promote(other))
end #|
end #Regexp
