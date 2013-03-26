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

