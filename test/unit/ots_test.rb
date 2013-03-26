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
include OTS::Constants
def test_initialize
	assert_not_nil(OTS.new)
end #initialize
def test_all
	assert(File.exists?('..'))
	assert(File.exists?('test/data_sources'), Dir['../*'].inspect)
	assert(File.exists?('test/data_sources'))
	assert(File.exists?('test/data_sources/US_1040_template.txt'))
	ret=IO.readlines('test/data_sources/US_1040_template.txt').map do |r| #map
		symbol_pattern="[A-Z0-9?]+"
		matchData=Full_regexp.match(r)
		if matchData then
			hash={:name => matchData[1], :type => matchData[2], :description => matchData[3]}
			assert_equal(3, matchData[1..3].size)
			assert_match(/#{symbol_pattern}/, r)
			assert_match(/^#{symbol_pattern}/, r)
			name=matchData[1]
			type=matchData[2]
			description=matchData[3].strip
			ots=OTS.new([name, type, description], [:name, :type, :description], [String, String, String])
		elsif matchData3=Symbol_pattern.match(r) then
			assert(matchData3, r.inspect)
		elsif matchData2=Delimiter_regexp.match(r) then
			assert(matchData2, matchData3.inspect)
		elsif matchData1=Type_regexp.match(r) then
			assert(matchData1, matchData2.inspect)
		elsif matchData0=Description_regexp.match(r) then
			assert(matchData, matchData1.inspect+r)
		else
			puts r
		end #if
		ots
	end.compact #map
	assert_empty(ret, ret.inspect)
end #all
end #OTS
