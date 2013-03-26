###########################################################################
#    Copyright (C) 2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative 'default_test_case.rb'
require_relative '../../app/models/ots.rb'
class OTSTest < DefaultTestCase2
include DefaultTests2
def test_initialize
	assert_not_nil(OTS.new)
end #initialize
def test_all
	assert(File.exists?('..'))
	assert(File.exists?('test/data_sources'), Dir['../*'].inspect)
	assert(File.exists?('test/data_sources'))
	assert(File.exists?('test/data_sources/US_1040_template.txt'))
	IO.readlines('test/data_sources/US_1040_template.txt').map do |r| #map
		symbol_pattern="[A-Z0-9?]+"
		matchData=/#{symbol_pattern}/.match(r)
		matchData=/(#{symbol_pattern})/.match(r)
		matchData=/(#{symbol_pattern})\s+/.match(r)
		matchData=/(#{symbol_pattern})\s+(0|\?\?)/.match(r)
		matchData=/(#{symbol_pattern})\s+(\?\?|0)\s+\{.+\}/.match(r)
		if matchData then
			hash={:name => matchData[1], :type => matchData[2], :description => matchData[3]}
			OTS.new(hash)
	#		assert_match(symbol_pattern, r)
			assert_match(/#{symbol_pattern}/, r)
			assert_match(/^#{symbol_pattern}/, r)
		end #if
	end #map
end #all
end #OTS
