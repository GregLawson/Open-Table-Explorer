###########################################################################
#    Copyright (C) 2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative '../../app/models/open_tax_solver.rb'
require_relative '../assertions/regexp_parse_assertions.rb'
class OpenTaxSolverTest < DefaultTestCase2
include DefaultTests
include OpenTaxSolver::Constants
extend OpenTaxSolver::Constants
include OpenTaxSolver::Examples
extend OpenTableExplorer::Finance::Constants
def test_Constants
	assert_pathname_exists(Data_source_directory)
	assert_pathname_exists(Open_Tax_Filler_Directory)
	assert_pathname_exists(Open_tax_solver_directory)
	assert_pathname_exists(Open_tax_solver_data_directory)
	assert_pathname_exists(Open_tax_solver_input)
	assert_pathname_exists(Open_tax_solver_binary)
	assert_pathname_exists(OTS_template_filename)
end #Constants
def test_initialize
end #initialize
def test_run_tax_solver
	form='1040'
	jurisdiction=:US
	sysout=`#{Command}`
	puts "test_run_tax_solver sysout=#{sysout}"
	form=OpenTableExplorer::Finance::TaxForms.new(form, jurisdiction)
	form.run_open_tax_solver
	assert_pathname_exists(Open_tax_solver_sysout)
end #run_open_tax_solver
def 	test_run_tax_solver_to_filler
	sysout=`nodejs #{Open_Tax_Filler_Directory}/script/json_ots.js #{Open_tax_solver_sysout} > #{Data_source_directory}/US_1040_OTS.json`
	puts "test_run_tax_solver_to_Form_filler sysout=#{sysout}"
	OpenTableExplorer::Finance::TaxForms.new('1040', :US).run_open_tax_solver_to_filler
end #run_open_tax_solver_to_filler
def 	test_run_tax_form_filler
#
#2. In the main directory, run
#./script/fillin_values FORM_NAME INPUT.json OUTPUT_FILE
#where form name is something like f8829 or f1040.
#3. Your OUTPUT_FILE should be your desired pdf filename.
#	sysout=`#{Open_Tax_Filler_Directory}/script/fillin_values FORM_NAME {Data_source_directory}/US_1040_OTS.json {Data_source_directory}/otff_output.pdf`

#!/bin/bash

#: ${YEAR_DIR:=2012}
#FORM=$1
#DATA=$2
#FDF=/tmp/output.fdf

#node script/apply_values.js ${YEAR_DIR}/definition/${FORM}.json \
#       ${YEAR_DIR}/transform/${FORM}.json ${DATA} > /tmp/output.fdf

#pdftk ${YEAR_DIR}/PDF/${FORM}.pdf fill_form ${FDF} output $3
	form='Federal/f1040'
	form_filename=form.sub('/','_')
	year_dir='2012'
	data="#{Data_source_directory}/US_1040_OTS.json"
	assert(File.exists?(data))
	fdf='/tmp/output.fdf'
	output_pdf="#{Data_source_directory}/#{form_filename}_otff.pdf"
	assert(File.exists?(data))
	pdf_input="#{Open_Tax_Filler_Directory}/"
#	assert(File.exists?(data))
	sysout=`nodejs #{Open_Tax_Filler_Directory}/script/apply_values.js #{Open_Tax_Filler_Directory}/#{year_dir}/definition/#{form}.json #{Open_Tax_Filler_Directory}/#{year_dir}/transform/#{form}.json #{data} > #{fdf}`
	assert_equal('', sysout, "nodejs sysout=#{sysout}")

	assert(File.exists?(Data_source_directory), Data_source_directory+' does not exist')
	sysout=`pdftk #{Open_Tax_Filler_Directory}/#{year_dir}/PDF/#{form}.pdf fill_form #{fdf} output #{output_pdf}`
#	assert(File.exists?(Data_source_directory+'Federal_f1040_otff.pdf'), Dir[Data_source_directory+'*'].join(';'))
#debug	sysout=`evince Data_source_directory+Federal_f1040_otff.pdf`
#	assert_equal('', sysout, "evince sysout=#{sysout}")
	
	sysout=`pdftoppm -jpeg  #{output_pdf} #{form_filename}`
#	assert_equal('', sysout, "pdftoppm sysout=#{sysout}")
	sysout=`display  Federal_f1040-1.jpg`
	assert_equal('', sysout, "display sysout=#{sysout}")
#	assert(File.exists?(output_pdf), "output_pdf=#{output_pdf}"+caller_lines)
end #test_run_tax_form_filler
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
	ios=OpenTaxSolver.parse
	assert_instance_of(Array, ios)
	assert_instance_of(Hash, ios[0])
#	assert_equal('L',ios[0][:name])
#	assert_equal('??', ios[0][:type_chars])
#	assert_equal('e',ios[0][:description])
end #parse
def test_raw_acquisitions
	assert_equal(1, OpenTaxSolver.raw_acquisitions.size)
end #raw_acquisitions
def test_coarse_filter
	assert_not_empty(OpenTaxSolver.coarse_filter.compact, OpenTaxSolver.coarse_filter.inspect)
	assert_operator(80, :<=, OpenTaxSolver.coarse_filter.size, OpenTaxSolver.coarse_filter.inspect)
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
		else
			nil
		end #if
	end.compact #select
	assert_operator(80, :<=, OpenTaxSolver.all.size, OpenTaxSolver.fine_rejections.inspect)
	OpenTaxSolver.all.each do |ots|
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
def test_dump_sql_to_file
	assert_equal(:OpenTaxSolver, model_name?)
	filename="db/SQL/Export/#{model_name?}_#{Default_tax_year}.sql"
	assert_respond_to(model_class?, :dump_sql_to_file)
	model_class?.dump_sql_to_file(filename)
end #dump_sql_to_file
end #OpenTaxSolver
