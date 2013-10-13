###########################################################################
#    Copyright (C) 2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative '../../app/models/tax_form.rb'
require_relative '../assertions/regexp_parse_assertions.rb'
class TaxFormTest < TestCase
include DefaultTests
include OpenTableExplorer::Finance::Constants
extend OpenTableExplorer::Finance::Constants
include OpenTableExplorer::Finance::TaxForm::Examples
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
	form=OpenTableExplorer::Finance::TaxForm.new(form, jurisdiction)
	form.run_open_tax_solver
	assert_pathname_exists(Open_tax_solver_sysout)
end #run_open_tax_solver
def 	test_run_tax_solver_to_filler
	sysout=`nodejs #{Open_Tax_Filler_Directory}/script/json_ots.js #{Open_tax_solver_sysout} > #{Data_source_directory}/US_1040_OTS.json`
	puts "test_run_tax_solver_to_Form_filler sysout=#{sysout}"
	OpenTableExplorer::Finance::TaxForm.new('1040', :US).run_open_tax_solver_to_filler
end #run_open_tax_solver_to_filler
def 	test_run_pdf_to_jpeg
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
end #run_pdf_to_jpeg
end #TaxForm
