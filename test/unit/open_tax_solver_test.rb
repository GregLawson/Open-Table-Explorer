###########################################################################
#    Copyright (C) 2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative 'default_test_case.rb'
require_relative '../../app/models/open_tax_solver.rb'
require_relative '../assertions/regexp_parse_assertions.rb'
class OpenTaxSolverTest < DefaultTestCase2
include DefaultTests2
include OpenTaxSolver::Constants
include OpenTaxSolver::Examples
def test_CLASS_constants
	assert_match(/#{Symbol_pattern}/, Simple_acquisition)
	assert_match(/#{Delimiter}/, Simple_acquisition)
	assert_match(/#{Type_pattern}/, Simple_acquisition)
	assert_match(/#{Description_pattern}/, Simple_acquisition)
	assert_match(Symbol_regexp, Simple_acquisition)
	assert_match(Type_regexp, Simple_acquisition)
	assert_match(Description_regexp, Simple_acquisition)
	assert_match(Full_regexp, Simple_acquisition)
	OpenTaxSolver.assert_post_conditions

end #Constants
def test_initialize
	assert_not_nil(OpenTaxSolver.new)
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

	OpenTaxSolver.assert_full_match(acquisition)
	ios=OpenTaxSolver.parse(acquisition, Full_regexp)
	assert_instance_of(Array, ios)
	assert_instance_of(Hash, ios[0])
	assert_equal('L',ios[0][:name])
	assert_equal('??', ios[0][:type_chars])
	assert_equal('e',ios[0][:description])
end #parse
def test_raw_acquisitions
	assert_equal(1, OpenTaxSolver.raw_acquisitions.size)
end #raw_acquisitions
def test_coarse_filter
	assert_not_empty(OpenTaxSolver.coarse_filter.compact, OpenTaxSolver.coarse_filter.inspect)
	assert_operator(84, :==, OpenTaxSolver.coarse_filter.size, OpenTaxSolver.coarse_filter.inspect)
end #coarse_filter
def test_coarse_rejections
	OpenTaxSolver.coarse_rejections.each do |acquisition|
		puts acquisition if Type_regexp.match(acquisition) 
		puts acquisition if Description_regexp.match(acquisition)
	end #select
	assert_operator(31, :==, OpenTaxSolver.coarse_rejections.size, OpenTaxSolver.coarse_rejections.inspect)
end #coarse_rejections
def test_all
	ret=OpenTaxSolver.coarse_filter.map do |r| #map
		matchData=Full_regexp.match(r)
		if matchData then
			OpenTaxSolver.assert_full_match(r)
			ios=OpenTaxSolver.parse(r, Full_regexp)
			ios[0][:tax_year]=Default_tax_year
		else
			nil
		end #if
	end.compact #select
	assert_not_empty(ret.compact, ret.inspect)
	assert_operator(84, :==, OpenTaxSolver.all.size, OpenTaxSolver.fine_rejections.inspect)
	OpenTaxSolver.all(Default_tax_year).each do |ots|
		assert_instance_of(OpenTaxSolver, ots)
		assert_instance_of(Hash, ots.attributes)
		assert_respond_to(ots.attributes, :values)
		assert_scope_path(:DefaultAssertions, :ClassMethods)
		assert_constant_instance_respond_to(:NoDB, :insert_sql)
		assert_include(ots.class.included_modules, NoDB)
#		assert_include(NoDB.methods, :insert_sql)
		assert_includes(OpenTaxSolver.methods, :insert_sql)
		explain_assert_respond_to(OpenTaxSolver, :insert_sql)
		assert_respond_to(OpenTaxSolver, :insert_sql)
		assert_instance_of(Array, ots.attributes.values)
		ots.assert_pre_conditions
		values=ots.insert_sql
	end #each
	assert_instance_of(Array, OpenTaxSolver.dump)
	assert_instance_of(String, OpenTaxSolver.dump[0])
	assert_not_equal('"', OpenTaxSolver.dump[0][0], OpenTaxSolver.dump[0][0..20])
	assert_equal("\n", OpenTaxSolver.dump[0][-1], OpenTaxSolver.dump[0][0..20])
	IO.binwrite(OTS_SQL_dump_filename, OpenTaxSolver.dump.join(''))
end #all
def test_fine_rejections
	OpenTaxSolver.fine_rejections.each do |r|
		OpenTaxSolver.assert_full_match(r)
	end #each
end #fine_rejections
def test_assert_full_match
	OpenTaxSolver.assert_full_match(" A28            ;       { Other deductions, listed on Sched-A page A-6.}\n")
	OpenTaxSolver.assert_full_match("L            0       { Other deductions, listed on Sched-A page A-6.}\n")
	OpenTaxSolver.assert_full_match("L            ;       { Other deductions, listed on Sched-A page A-6.}\n")
	OpenTaxSolver.assert_full_match("L            ??       { Other deductions, listed on Sched-A page A-6.}\n")
	OpenTaxSolver.assert_full_match("L                   { Other deductions, listed on Sched-A page A-6.}\n")
	OpenTaxSolver.assert_full_match('L ?? {e}')
	OpenTaxSolver.assert_full_match('L 0 {e}')
	OpenTaxSolver.assert_full_match('L ; {e}')
	
	OpenTaxSolver.assert_full_match("L            ;       { Other deductions, listed on Sched-A page A-6.}\n")
	OpenTaxSolver.assert_full_match('L ; {e}')
	OpenTaxSolver.assert_full_match('L ?? {e}')
	OpenTaxSolver.assert_full_match('L  {e}')	

end #assert_full_match
end #OpenTaxSolver
