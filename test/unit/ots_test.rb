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
include OTS::Examples
def test_CLASS_constants
	assert_match(/#{Symbol_pattern}/, Simple_acquisition)
	assert_match(/#{Delimiter}/, Simple_acquisition)
	assert_match(/#{Type_pattern}/, Simple_acquisition)
	assert_match(/#{Description_pattern}/, Simple_acquisition)
	assert_match(Symbol_regexp, Simple_acquisition)
	assert_match(Type_regexp, Simple_acquisition)
	assert_match(Description_regexp, Simple_acquisition)
	assert_match(Full_regexp, Simple_acquisition)
	OTS.assert_post_conditions

end #Constants
def test_initialize
	assert_not_nil(OTS.new)
end #initialize
def test_parse
	assert_match(/(;)/, ';')
	assert_match(/(\?\?|0|;)/, '0')
	assert_match(/(\?\?|0|;)/, ';')
	assert_match(/(\?\?|0|;)/, '??')
	assert_match(/#{Type_pattern}/, ' 0 ')
	assert_match(/#{Type_pattern}/, ' ?? ')
	assert_match(/#{Type_pattern}/, ' ; ')
	acquisition="L            ??       { e}\n"

	matchData=Symbol_regexp.match(acquisition)
	assert_equal('L',matchData[1])

	matchData=Type_regexp.match(acquisition)
	assert_equal('L',matchData[1])

	matchData=Description_regexp.match(acquisition)
	assert_equal(' e',matchData[-1])

	matchData=Full_regexp.match(acquisition)
	assert_equal('L',matchData[1])
	assert_equal(matchData[2], matchData[3] || matchData[5] || matchData[7] , matchData.inspect)
	assert_equal('0', md=Full_regexp.match('L 0 {e}')[6], md.inspect)
	type=matchData[10] || matchData[4] || matchData[6] || matchData[8]
	assert_include(['??', ';', '0'],type, matchData.inspect)

	OTS.assert_full_match(acquisition)
	ios=OTS.parse(acquisition, Full_regexp)
	assert_equal('L',ios[:name])
	assert_equal('??', ios[:type])
	assert_equal('e',ios[:description])
end #parse
def test_raw_acquisitions
	assert_equal(115, OTS.raw_acquisitions.size)
end #raw_acquisitions
def test_coarse_filter
	assert_not_empty(OTS.coarse_filter.compact, OTS.coarse_filter.inspect)
	assert_operator(84, :==, OTS.coarse_filter.size, OTS.coarse_filter.inspect)
end #coarse_filter
def test_coarse_rejections
	OTS.coarse_rejections.each do |acquisition|
		puts acquisition if Type_regexp.match(acquisition) 
		puts acquisition if Description_regexp.match(acquisition)
	end #select
	assert_operator(31, :==, OTS.coarse_rejections.size, OTS.coarse_rejections.inspect)
end #coarse_rejections
def test_all
	ret=OTS.coarse_filter.map do |r| #map
		matchData=Full_regexp.match(r)
		if matchData then
			OTS.assert_full_match(r)
			ios=OTS.parse(r, Full_regexp)
		else
			nil
		end #if
	end.compact #select
	assert_not_empty(ret.compact, ret.inspect)
	assert_operator(84, :==, OTS.all.size, OTS.fine_rejections.inspect)
	OTS.all.each do |ots|
		assert_instance_of(OTS, ots)
		assert_instance_of(Hash, ots.attributes)
		assert_respond_to(ots.attributes, :values)
		assert_scope_path(:DefaultAssertions, :ClassMethods)
		assert_constant_instance_respond_to(:NoDB, :insert_sql)
		assert_include(ots.class.included_modules, NoDB)
#		assert_include(NoDB.methods, :insert_sql)
		assert_includes(OTS.methods, :insert_sql)
		explain_assert_respond_to(OTS, :insert_sql)
		assert_respond_to(OTS, :insert_sql)
		assert_instance_of(Array, ots.attributes.values)
		ots.assert_pre_conditions
		values=ots.insert_sql
	end #each
	IO.write(OTS_SQL_dump_filename, OTS.dump)
end #all
def test_fine_rejections
	OTS.fine_rejections.each do |r|
		OTS.assert_full_match(r)
	end #each
end #fine_rejections
def test_assert_full_match
	OTS.assert_full_match(" A28            ;       { Other deductions, listed on Sched-A page A-6.}\n")
	OTS.assert_full_match("L            0       { Other deductions, listed on Sched-A page A-6.}\n")
	OTS.assert_full_match("L            ;       { Other deductions, listed on Sched-A page A-6.}\n")
	OTS.assert_full_match("L            ??       { Other deductions, listed on Sched-A page A-6.}\n")
	OTS.assert_full_match("L                   { Other deductions, listed on Sched-A page A-6.}\n")
	OTS.assert_full_match('L ?? {e}')
	OTS.assert_full_match('L 0 {e}')
	OTS.assert_full_match('L ; {e}')
	
	OTS.assert_full_match("L            ;       { Other deductions, listed on Sched-A page A-6.}\n")
	OTS.assert_full_match('L ; {e}')
	OTS.assert_full_match('L ?? {e}')
	OTS.assert_full_match('L  {e}')	

end #assert_full_match
end #OTS
