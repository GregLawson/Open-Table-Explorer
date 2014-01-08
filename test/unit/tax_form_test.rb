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
def model_class?
	OpenTableExplorer::Finance::TaxForm
end #model_class?
include DefaultTests
include OpenTableExplorer::Finance::Constants
extend OpenTableExplorer::Finance::Constants
include OpenTableExplorer::Finance::TaxForm::Examples
def test_Constants
	assert_pathname_exists(Data_source_directory, 'mkdir test/data_sources/tax_form')
	assert_pathname_exists(Open_Tax_Filler_Directory)
#	assert_pathname_exists(Open_tax_solver_examples_directory)
#	assert_pathname_exists(Open_tax_solver_data_directory)
#	assert_pathname_exists(Open_tax_solver_input)
#	assert_pathname_exists(Open_tax_solver_binary)
#	assert_pathname_exists(OTS_template_filename)
end #Constants
def test_initialize
	form='1040'
	jurisdiction=:US
#	sysout=`#{Command}`
#	puts "test_run_tax_solver sysout=#{sysout}"
	form=OpenTableExplorer::Finance::TaxForm.new(:example, form, jurisdiction)
	assert_pathname_exists(form.open_tax_solver_directory)
	assert_pathname_exists(form.open_tax_solver_data_directory)
#	assert_pathname_exists(form.ots_template_filename)
#	assert_pathname_exists(form.output_pdf)
	assert_equal(:US, US1040_template.jurisdiction)
	assert_equal('1040', US1040_template.form)
	assert_equal('US_1040', US1040_template.form_filename)
	assert_equal(:US, US1040_example.jurisdiction)
	assert_equal('1040', US1040_example.form)
	assert_equal('US_1040', US1040_example.form_filename)
	assert_equal(:US, US1040_user.jurisdiction)
	assert_equal('1040', US1040_user.form)
	assert_equal('US_1040', US1040_user.form_filename)
	assert_match(/CA_540_2012$/, CA540_example.open_tax_solver_binary)
	assert_equal('US_1040_example', US1040_example.taxpayer_basename)
	assert_equal('US_1040_example1', US1040_example1.taxpayer_basename)
	assert_equal('CA_540_2012_example', CA540_example.taxpayer_basename)
	assert_pathname_exists(CA540_template.open_tax_solver_data_directory+'/'+CA540_template.taxpayer_basename_with_year+'.txt')
	assert_equal('CA_540_2012_template', CA540_template.taxpayer_basename)
end #initialize
def test_build
	US1040_example.build.assert_build.assert_pdf_to_jpeg
	CA540_example.build.assert_build.assert_pdf_to_jpeg
	US1040_user.build.assert_build.assert_pdf_to_jpeg
	CA540_user.build.assert_build.assert_pdf_to_jpeg
	US1040_example1.build.assert_build.assert_open_tax_solver
	US1040_template.build.assert_build.assert_open_tax_solver
	CA540_template.build.assert_build.assert_open_tax_solver
#	Repository.new(Data_source_directory).git_command('git diff edited -- test/data_sources/tax_form/CA_540/CA_540_2012_example_out.txt').assert_post_conditions
end #build
def test_run_tax_solver
	form='1040'
	jurisdiction=:US
	form=OpenTableExplorer::Finance::TaxForm.new(:example, form, jurisdiction)
	
	form.run_open_tax_solver
	form.assert_open_tax_solver
	US1040_example.run_open_tax_solver.assert_open_tax_solver
	US1040_user.run_open_tax_solver.assert_open_tax_solver
	CA540_user.run_open_tax_solver.assert_open_tax_solver
	US1040_template.run_open_tax_solver.assert_open_tax_solver
	CA540_template.run_open_tax_solver.assert_open_tax_solver
	CA540_example.run_open_tax_solver.assert_open_tax_solver
	US1040_example1.run_open_tax_solver.assert_open_tax_solver
end #run_open_tax_solver
def 	test_run_tax_solver_to_filler
	assert_pathname_exists(Open_Tax_Filler_Directory)
	open_tax_form_filler_ots_js="#{Open_Tax_Filler_Directory}/script/json_ots.js"
	assert_pathname_exists(open_tax_form_filler_ots_js)
	US1040_template.run_ots_to_json.ots_to_json_run.assert_post_conditions
	US1040_example.run_ots_to_json.ots_to_json_run.assert_post_conditions
	CA540_template.run_ots_to_json.ots_to_json_run.assert_post_conditions
	CA540_example.run_ots_to_json.ots_to_json_run.assert_post_conditions
	OpenTableExplorer::Finance::TaxForm.new(:example, '1040', :US).run_ots_to_json
	US1040_user.run_ots_to_json.ots_to_json_run.assert_post_conditions
	CA540_user.run_ots_to_json.ots_to_json_run.assert_post_conditions
end #run_ots_to_json
def test_run_json_to_fdf
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
	US1040_template.run_json_to_fdf.assert_json_to_fdf
	US1040_example.run_json_to_fdf.assert_json_to_fdf
#	CA540_template.run_json_to_fdf.assert_json_to_fdf
#	CA540_example.run_json_to_fdf.assert_json_to_fdf
	US1040_user.run_json_to_fdf.assert_json_to_fdf
#	CA540_user.run_json_to_fdf.assert_json_to_fdf
end #run_json_to_fdf
def test_run_fdf_to_pdf
#	US1040_template.run_fdf_to_pdf.assert_fdf_to_pdf
#	US1040_example.run_fdf_to_pdf.assert_fdf_to_pdf
#	CA540_template.run_fdf_to_pdf.assert_fdf_to_pdf
#	CA540_example.run_fdf_to_pdf.assert_fdf_to_pdf
#	US1040_user.run_fdf_to_pdf.assert_fdf_to_pdf
#	CA540_user.run_fdf_to_pdf.assert_fdf_to_pdf
end #run_json_to_pdf
def 	test_run_pdf_to_jpeg
#	US1040_template.run_pdf_to_jpeg.assert_pdf_to_jpeg
#	US1040_example.run_pdf_to_jpeg.assert_pdf_to_jpeg
#	CA540_template.run_pdf_to_jpeg.assert_pdf_to_jpeg
#	CA540_example.run_pdf_to_jpeg.assert_pdf_to_jpeg
#	US1040_user.run_pdf_to_jpeg.assert_pdf_to_jpeg
#	CA540_user.run_pdf_to_jpeg.assert_pdf_to_jpeg
end #run_pdf_to_jpeg
def test_Examples
	OpenTableExplorer::Finance::TaxForm::Examples.constants.each do |e|
		value=eval(e.to_s)
		if value.instance_of?(OpenTableExplorer::Finance::TaxForm) then
			message="value=#{value.inspect}\n"
			assert_instance_of(OpenTableExplorer::Finance::TaxForm, value, message)
			assert_not_empty("../OpenTaxSolver#{Default_tax_year}_*")
			assert_not_empty(Dir["../OpenTaxSolver#{Default_tax_year}_*"], Dir["../OpenTaxSolver*"].inspect)
			assert_not_nil(Dir["../OpenTaxSolver#{Default_tax_year}_*"].sort[-1])
			assert_not_nil(value.open_tax_solver_directory, 'constant name='+e.to_s+"\n"+message)
			assert_pathname_exists(value.open_tax_solver_directory, 'constant name='+e.to_s+"\n"+"")
			assert_pathname_exists(value.open_tax_solver_data_directory, 'constant name='+e.to_s+"\n")
			assert_pathname_exists(value.open_tax_solver_input, 'constant name='+e.to_s+"\n")
			value.assert_pre_conditions('constant name='+e.to_s+"\n")
			value.assert_post_conditions('constant name='+e.to_s+"\n")
		end #if
	end #each
	assert_pathname_exists(US1040_user.open_tax_solver_input)
	assert_pathname_exists(CA540_user.open_tax_solver_input)
end #Examples
end #TaxForm
