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
require_relative '../assertions/regexp_parse_assertions.rb'
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
	assert_match(/(;)/, ';')
	assert_match(/(\?\?|0|;)/, '0')
	assert_match(/(\?\?|0|;)/, ';')
	assert_match(/(\?\?|0|;)/, '??')
	assert_match(/#{Type_pattern}/, '0')
	assert_match(/#{Type_pattern}/, '0')
	assert_match(/#{Type_pattern}/, '??')
	assert_match(/#{Type_pattern}/, ';')
	ret=IO.readlines('test/data_sources/US_1040_template.txt').map do |r| #map
		matchData=Full_regexp.match(r)
		matchData3=Symbol_pattern.match(r)
		matchData2=Delimiter_regexp.match(r)
		matchData1=Type_regexp.match(r)
		matchData0=Description_regexp.match(r)
		if matchData then
			hash={:name => matchData[1], :type => matchData[2], :description => matchData[3]}
			assert_equal(3, matchData[1..3].size)
			assert_match(/#{Symbol_pattern}/, r)
			assert_match(/^#{Symbol_pattern}/, r)
			name=matchData[1]
			type=matchData[2]
			description=matchData[3].strip
			ots=OTS.new([name, type, description], [:name, :type, :description], [String, String, String])
		elsif matchData0 then
			puts "Description_regexp"+matchData0.inspect+r
			rest=matchData2.post_match
			badMatch=/#{Description_pattern}/.match(rest)
			puts "badMatch="+badMatch.inspect
			assert_match(/\{/, rest)
			assert_match(/\{(.+)\}/, rest)
			assert_match(/\{([.]+)\}/, rest)
		elsif matchData1 then
			assert(matchData1, matchData2.inspect)
			puts "Type_regexp"+r
		elsif matchData2 then
			rest=matchData2.post_match
			badMatch=/#{Type_pattern}/.match(rest)
			puts "/0|;/.match(rest[0])=#{/0|;/.match(rest[0]).inspect}"
			puts "/#{Type_pattern}/.match(rest[0])=#{/#{Type_pattern}/.match(rest[0]).inspect}"
			puts "/#{Type_pattern}/.match(rest)=#{/#{Type_pattern}/.match(rest).inspect}"
			assert(matchData2, matchData3.inspect)
			puts "Delimiter_regexp: matchData2=#{matchData2.inspect}\nmatchData2.post_match=#{matchData2.post_match.inspect}\n#{r.inspect}"
			
			puts "Full_regexp matchData=#{matchData.inspect}"
			puts "Delimiter_regexp matchData3=#{matchData3.inspect}"
			puts "matchData2=#{matchData2.inspect}"
			puts "matchData1=#{matchData1.inspect}"
			puts "matchData0=#{matchData0.inspect}"

		elsif matchData3 then
			assert(matchData3, r.inspect)
			puts "Symbol_pattern"+r
		else
#			puts r
		end #if
		ots
	end.compact #map
	assert_empty(ret, ret.inspect)
end #all
end #OTS
