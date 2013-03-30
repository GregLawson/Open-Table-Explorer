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
Type_pattern='(\s+|'+['\?\?', '0', ';', 'Yes'].map{|a| '('+Delimiter+'('+a+')'+Delimiter+')'}.join('|')+')'
Description_pattern='\{(.+)\}'
Symbol_regexp=/#{Symbol_pattern}/
Type_regexp=/#{Symbol_pattern}#{Type_pattern}/
Description_regexp=/#{Description_pattern}/
Full_regexp=/#{Symbol_pattern}#{Type_pattern}#{Description_pattern}/
end #Constants
def self.parse(acquisition, pattern=Full_regexp) #acquisition=next
	matchData=pattern.match(acquisition)
	name=matchData[1]
	type=matchData[4] || matchData[6] || matchData[8] || matchData[2] # 
	description=matchData[-1] #.strip
	OTS.new([name, type, description], [:name, :type, :description], [String, String, String])
end #parse
def self.raw_acquisitions
	IO.readlines('test/data_sources/US_1040_template.txt')
end #raw_acquisitions
def self.coarse_filter
	raw_acquisitions.select do |acquisition|
		Type_regexp.match(acquisition) && Description_regexp.match(acquisition)
	end #select
end #coarse_filter
def self.coarse_rejections
	raw_acquisitions.select do |acquisition|
		!(Type_regexp.match(acquisition) && Description_regexp.match(acquisition))
	end #select
end #coarse_rejections
def self.all
	coarse_filter.map do |r| #map
		matchData=Full_regexp.match(r)
		if matchData then
			ios=parse(r, Full_regexp)
		else
			nil
		end #if
	end.compact #map
end #all
module Examples
Simple_acquisition='L 0 {e}'
Short_acquisition='L  {e}'

end #Examples
require_relative '../../test/assertions/default_assertions.rb'

module Assertions
include Test::Unit::Assertions
extend Test::Unit::Assertions
def assert_pre_conditions
	assert_instance_of(Class, self)
end #assert_pre_conditions
module ClassMethods
include OTS::Constants
include OTS::Examples
include Test::Unit::Assertions
extend Test::Unit::Assertions
include DefaultAssertions::ClassMethods
def assert_post_conditions
	assert_scope_path(:DefaultAssertions, :ClassMethods)
#	assert_constant_instance_respond_to(:DefaultAssertions, :ClassMethods, :value_of_example?) #, "In assert_post_conditions calling assert_constant_instance_respond_to"
	Examples.constants.each do |name|
		example_acquisition=OTS.value_of_example?(name)
		assert_match(/#{Symbol_pattern}/, example_acquisition)
		assert_match(/#{Delimiter}/, example_acquisition)
		assert_match(/#{Type_pattern}/, example_acquisition)
		assert_match(/#{Description_pattern}/, example_acquisition)
		assert_match(Symbol_regexp, example_acquisition)
		assert_match(Type_regexp, example_acquisition)
		assert_match(Description_regexp, example_acquisition)
		assert_match(Full_regexp, example_acquisition)
	end #each
#hit	fail "end of CLASS assert_post_conditions"
end #assert_post_conditions
def assert_full_match(acquisition)
	matchData=Full_regexp.match(acquisition)
	assert_equal(12, matchData.size, matchData.inspect)
	matchMap=[matchData[2].nil?, matchData[4].nil?, matchData[6].nil?, matchData[8].nil?]
	case matchMap
	when [false, false, true, true] then assert_equal('??', matchData[4], matchData.inspect)
	when [false, true, false, true] then assert_equal('0', matchData[6], matchData.inspect)
	when [false, true, true, false] then assert_equal(';', matchData[8], matchData.inspect)
	when [false, true, true, true] then assert_match(/\s+/, matchData[2], matchData.inspect)
	else
		fail matchMap.inspect
	end #case
end #assert_match
end #ClassMethods
end #Assertions
require_relative '../../test/assertions/default_assertions.rb'
include Assertions
include Examples
include Constants
extend Assertions::ClassMethods
end #OTS

