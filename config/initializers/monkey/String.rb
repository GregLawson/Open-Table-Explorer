###########################################################################
#    Copyright (C) 2010-2012 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################

class String
# Create Regexp that exactly matches String.
# Special Regexp characters are escaped
# Other special cases may exist like '<'
def to_exact_regexp(options=RegexpTree::Default_options)
	return Regexp.new(Regexp.escape(self), options)
end #to_exact_regexp
# Convert String to Array of one character Strings
# Why would this be useful? It doesn't distinquish Regexp special characters
# It was designed for unpacking binary data into Arrays
# See http://ruby-doc.org/core-1.9.3/String.html#method-i-unpack
# it could be a check on parsing:
# string.to_a=string.to_regexp_exact.source
def to_a(format='a', packed_length=1)
	array_length=size/packed_length
	ret=(0..array_length-1).to_a.map do |i|
		self[i*packed_length,packed_length].unpack(format)[0]
	end #map
	return ret
end #to_a
end #String
