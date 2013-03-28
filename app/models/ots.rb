###########################################################################
#    Copyright (C) 2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../../app/models/no_db.rb'
class OTS
include NoDB
extend NoDB::ClassMethods
module Constants
Symbol_pattern='^ ?([-A-Za-z0-9?]+)'
Delimiter='\s+'
Type_pattern='(\?\?|0|;|Yes)'
#Type_pattern='([?0;]+)'
Delimiter2='.+'
Description_pattern='\{(.+)\}'
Symbol_regexp=/#{Symbol_pattern}/
Delimiter_regexp=/#{Symbol_pattern}#{Delimiter}/
Type_regexp=/#{Symbol_pattern}#{Delimiter}#{Type_pattern}/
Description_regexp=/#{Symbol_pattern}#{Delimiter}#{Type_pattern}#{Delimiter2}/
Full_regexp=/#{Symbol_pattern}#{Delimiter}#{Type_pattern}#{Delimiter2}#{Description_pattern}/
end #Constants
def self.all
	IO.readlines('battery_types').map do |r| #map
		symbol_pattern="[A-Z0-9?]+"
		matchData=/(#{symbol_pattern})\s+(\?\?|0)\s+\{(.+)\}/.match(r)
		if matchData then
			OTS.new(matchData[1..3], [:name, :type, :description], [String, String, String])
		end #if
	end.compact #map
end #all
module Assertions
def assert_pre_conditions
	assert_instance_of(Class, self)
end #assert_pre_conditions
end #Assertions
require_relative '../../test/assertions/default_assertions.rb'
include DefaultAssertions
extend DefaultAssertions::ClassMethods
end #OTS

