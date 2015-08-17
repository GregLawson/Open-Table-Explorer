###########################################################################
#    Copyright (C) 2013-2015 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative '../../app/models/tax_form.rb'
#require_relative '../assertions/regexp_parse_assertions.rb'
class TaxFormTest < TestCase
def model_class?
	OpenTableExplorer::Finance::TaxForm
end #model_class?
include DefaultTests
include OpenTableExplorer::Finance::Constants
extend OpenTableExplorer::Finance::Constants
include OpenTableExplorer::Finance::TaxForm::Examples
def test_Constants
	assert_not_empty(OpenTaxSolver_directories, OpenTaxSolver_directories_glob)
	assert_pathname_exists(Open_Tax_Filler_Directory)

end #Constants
def test_open_tax_solver_distribution_directories
	assert_not_empty(Dir[Downloaded_src_dir+"OpenTaxSolver#{Default_tax_year}*-*"])
	assert_not_empty(OpenTableExplorer::Finance::TaxForm.open_tax_solver_distribution_directories(Default_tax_year))
	assert_pathname_exists(OTS_example_directories, 'mkdir test/data_sources/tax_form')
end # open_tax_solver_distribution_directories
def test_TaxForm_open_tax_solver_distribution_directory
	assert_pathname_exists(OpenTableExplorer::Finance::TaxForm.open_tax_solver_distribution_directory(Default_tax_year))
end # open_tax_solver_distribution_directory
def test_TaxForm_ots_example_all_forms_directory
	assert_pathname_exists(OTS_example_directories.to_s, OTS_example_directories.inspect)
	assert_pathname_exists(OTS_example_directories.to_s + '/' + Default_tax_year.to_s, OTS_example_directories.inspect)
	assert_pathname_exists(OTS_example_directories.to_s + '/' + Default_tax_year.to_s + '/examples_and_templates', OTS_example_directories.inspect)
	assert_pathname_exists(OTS_example_directories.to_s + '/' + Default_tax_year.to_s + '/examples_and_templates/', OTS_example_directories.inspect)
	assert_equal(OTS_example_directories.to_s + '/' + Default_tax_year.to_s + '/examples_and_templates/', OpenTableExplorer::Finance::TaxForm.ots_example_all_forms_directory.to_s)
	path_string = OTS_example_directories.to_s + '/' + Default_tax_year.to_s + '/examples_and_templates/'
	assert_pathname_exists(path_string, path_string.inspect)
	assert_pathname_exists(Pathname.new(path_string).expand_path)
	assert_pathname_exists(OpenTableExplorer::Finance::TaxForm.ots_example_all_forms_directory)
	assert_equal(OpenTableExplorer::Finance::TaxForm.ots_example_all_forms_directory, CA540_template.open_tax_solver_all_form_directory)
	assert_equal(OpenTableExplorer::Finance::TaxForm.ots_example_all_forms_directory, US1040_example.open_tax_solver_all_form_directory)
#	assert_equal(OpenTableExplorer::Finance::TaxForm.ots_example_all_forms_directory, US1040_example1.open_tax_solver_all_form_directory)
	assert_equal(OpenTableExplorer::Finance::TaxForm.ots_example_all_forms_directory, CA540_example.open_tax_solver_all_form_directory)
end # ots_example_all_forms_directory
def test_TaxForm_ots_user_all_forms_directory
	assert_equal(OpenTableExplorer::Finance::TaxForm.ots_user_all_forms_directory, US1040_user.open_tax_solver_all_form_directory)
	assert_equal(OpenTableExplorer::Finance::TaxForm.ots_user_all_forms_directory, CA540_user.open_tax_solver_all_form_directory)
	assert_pathname_exists(OpenTableExplorer::Finance::TaxForm.ots_user_all_forms_directory(@tax_year)+"/#{@form_filename}/")
end # ots_user_all_forms_directory
def test_open_tax_solver_distribution_directory
	assert_pathname_exists(US1040_template.open_tax_solver_distribution_directory)
end # open_tax_solver_distribution_directory
def test_initialize
	form='1040'
	jurisdiction=:US
#	sysout=`#{Command}`
#	puts "test_run_tax_solver sysout=#{sysout}"
	assert_equal('1040', US1040_template.form)
	assert_equal('1040', US1040_example.form)
	assert_equal('1040', US1040_user.form)
	assert_equal(:US, US1040_template.jurisdiction)
	assert_equal(:US, US1040_example.jurisdiction)
	assert_equal(:US, US1040_user.jurisdiction)
	assert_equal('US_1040', US1040_template.form_filename)
	assert_equal('US_1040', US1040_example.form_filename)
	assert_equal('US_1040', US1040_user.form_filename)
	assert_pathname_exists(US1040_example.open_tax_solver_all_form_directory)
	assert_not_nil(US1040_example.open_tax_solver_all_form_directory)
	tax_form = OpenTableExplorer::Finance::TaxForm.new(:example, form, jurisdiction, Default_tax_year, OpenTableExplorer::Finance::TaxForm.ots_user_all_forms_directory(@tax_year))
	assert_pathname_exists(tax_form.open_tax_solver_form_directory)
	assert_pathname_exists(US1040_template.open_tax_solver_form_directory)
	assert_pathname_exists(CA540_template.open_tax_solver_form_directory+'/'+CA540_template.taxpayer_basename_with_year+'.txt')
	assert_match(/CA_540_#{Default_tax_year}$/, CA540_example.open_tax_solver_binary)
	assert_equal('US_1040_example', US1040_example.taxpayer_basename)
#	assert_equal('US_1040_example1', US1040_example1.taxpayer_basename)
	assert_equal("CA_540_#{Default_tax_year}_example", CA540_example.taxpayer_basename)
	assert_equal("CA_540_#{Default_tax_year}_template", CA540_template.taxpayer_basename)
	assert_not_empty(Dir[CA540_example.output_xfdf_glob])
end #initialize
def test_example
	US1040_example.build.assert_build.assert_pdf_to_jpeg
	CA540_example.build
	CA540_example.assert_open_tax_solver
	CA540_example.assert_ots_to_json
	US1040_example.commit_minor_change!(Dir['test/data_sources/tax_form/*/*'], 'fixup! TaxForm update timestamps')
	CA540_example.build.assert_build
	CA540_example.build.assert_build.assert_ots_to_json
	CA540_example.assert_build
end #example
def test_user
	US1040_user.build.assert_build.assert_pdf_to_jpeg
#	CA540_user.build.assert_ots_to_json
end #user
def test_example1
	US1040_example1.build.assert_open_tax_solver
end #build
def test_template
	US1040_template.build.assert_open_tax_solver
#	CA540_template.build.assert_ots_to_json
#	Repository.new(ots_example_all_forms_directory).git_command('git diff edited -- test/data_sources/tax_form/CA_540/CA_540_2012_example_out.txt').assert_post_conditions
end #build
def test_commit_minor_change!
	file='test/data_sources/tax_form/CA_540/CA_540_2012_example_out.txt'
	current_branch_name=Repository::This_code_repository.current_branch_name?
	diff_run=Repository::This_code_repository.git_command('diff stash -- '+file).assert_post_conditions
	diff_run=Repository::This_code_repository.git_command("diff #{current_branch_name.to_s} -- "+file).assert_post_conditions
	assert_operator(diff_run.output.split.size, :<=, 8, diff_run.inspect)
	
#        modified:   test/data_sources/tax_form/CA_540/CA_540_2012_template_out.txt
#        modified:   test/data_sources/tax_form/US_1040/US_1040_example1_out.txt
#        modified:   test/data_sources/tax_form/US_1040/US_1040_example_out.txt
#        modified:   test/data_sources/tax_form/US_1040/US_1040_example_sysout.txt
#        modified:   test/data_sources/tax_form/US_1040/US_1040_template_out.txt
end #commit_minor_change!
def test_run_tax_solver
	form='1040'
	jurisdiction=:US
	tax_form = OpenTableExplorer::Finance::TaxForm.new(:example, form, jurisdiction, Default_tax_year, OpenTableExplorer::Finance::TaxForm.ots_user_all_forms_directory(@tax_year))
	command="#{tax_form.open_tax_solver_binary} #{tax_form.open_tax_solver_input} >#{tax_form.open_tax_solver_sysout}"
	open_tax_solver_run = ShellCommands.new(command, :chdir => tax_form.open_tax_solver_all_form_directory)
	open_tax_solver_run.assert_post_conditions
	tax_form.run_open_tax_solver
	tax_form.assert_open_tax_solver
#	assert_equal(tax_form, US1040_example.run_open_tax_solver)
	US1040_example.run_open_tax_solver.assert_open_tax_solver
	US1040_user.run_open_tax_solver.assert_open_tax_solver
	CA540_user.run_open_tax_solver.assert_open_tax_solver
	US1040_template.run_open_tax_solver.assert_open_tax_solver
	CA540_template.run_open_tax_solver.assert_open_tax_solver
	CA540_example.run_open_tax_solver.assert_open_tax_solver
#	US1040_example1.run_open_tax_solver.assert_open_tax_solver
end #run_open_tax_solver
#def test_run_ots_to_json
#	assert_pathname_exists(Open_Tax_Filler_Directory)
#	open_tax_form_filler_ots_js="#{Open_Tax_Filler_Directory}/script/json_ots.js"
#	assert_pathname_exists(open_tax_form_filler_ots_js)
#	US1040_template.run_ots_to_json.ots_to_json_run.assert_post_conditions
#	US1040_example.run_ots_to_json.ots_to_json_run.assert_post_conditions
#	CA540_template.run_ots_to_json.ots_to_json_run.assert_post_conditions
#	CA540_example.run_ots_to_json.ots_to_json_run.assert_post_conditions
#	OpenTableExplorer::Finance::TaxForm.new(:example, '1040', :US).run_ots_to_json
#	US1040_user.run_ots_to_json.ots_to_json_run.assert_post_conditions
#	CA540_user.run_ots_to_json.ots_to_json_run.assert_post_conditions
#end #run_ots_to_json
#def test_run_json_to_fdf
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
#	US1040_template.run_json_to_fdf.assert_json_to_fdf
#	US1040_example.run_json_to_fdf.assert_json_to_fdf
#	CA540_template.run_json_to_fdf.assert_json_to_fdf
#	CA540_example.run_json_to_fdf.assert_json_to_fdf
#	US1040_user.run_json_to_fdf.assert_json_to_fdf
#	CA540_user.run_json_to_fdf.assert_json_to_fdf
#end #run_json_to_fdf
def test_run_fdf_to_pdf
	Dir[US1040_example.output_xfdf_glob].each do |xfdf_file|
		jurisdiction_pattern = /#{@jurisdiction}/.capture(:jurisdiction)/
		form_pattern = /#{@form}/.capture(:form)
		taxpayer_pattern = /#{@taxpayer}/.capture(:taxpayer)
		schedule_pattern = /_f#{@form}/ * /[a-z]*/.capture(:schedule) * /.xfdf/
		xfdf_file_pattern = jurisdiction_pattern * /_/ * form_pattern * /_/ * taxpayer_pattern * schedule_pattern
		xfdf_file.capture?(xfdf_file_pattern)
	end # each
end # run_fdf_to_pdf
def 	test_run_pdf_to_jpeg
	output_pdf_pathname=Pathname.new(File.expand_path(US1040_example.output_pdf))
	assert_instance_of(Pathname, output_pdf_pathname)
	cleanpath_name=output_pdf_pathname.cleanpath
	clean_directory=Pathname.new(File.expand_path(US1040_example.open_tax_solver_form_directory)).cleanpath
	output_pdf=cleanpath_name.relative_path_from(clean_directory)
	US1040_example.build.assert_pdf_to_jpeg
#	US1040_template.run_pdf_to_jpeg.assert_pdf_to_jpeg
#	US1040_example.run_pdf_to_jpeg.assert_pdf_to_jpeg
#	CA540_template.run_pdf_to_jpeg.assert_pdf_to_jpeg
#	CA540_example.run_pdf_to_jpeg.assert_pdf_to_jpeg
#	US1040_user.run_pdf_to_jpeg.assert_pdf_to_jpeg
#	CA540_user.run_pdf_to_jpeg.assert_pdf_to_jpeg
end #run_pdf_to_jpeg
# Assertions custom instance methods
def test_assert_open_tax_solver
	CA540_example.build
	assert_not_nil(CA540_example.open_tax_solver_run, CA540_example.inspect)
	assert_not_nil(CA540_example.open_tax_solver_run.process_status, CA540_example.inspect)
	peculiar_status=CA540_example.open_tax_solver_run.process_status.exitstatus
	if File.exists?(CA540_example.open_tax_solver_sysout) then
		message=IO.binread(CA540_example.open_tax_solver_sysout)
	else
		message="file=#{CA540_example.open_tax_solver_sysout} does not exist"
	end #if
	message+=CA540_example.open_tax_solver_run.errors
	CA540_example.open_tax_solver_run.puts if $VERBOSE
	puts "peculiar_status=#{peculiar_status}" if $VERBOSE
	puts "message='#{message}'" if $VERBOSE
	case peculiar_status
	when 0 then 
		CA540_example.open_tax_solver_run.assert_post_conditions('else peculiar_status '+message)
	when 1 then
		# fed not found
		message+="\nfed input not found"
		message+="\nUS1040_example.open_tax_solver_output=#{US1040_example.open_tax_solver_output}\n"
		CA540_example.open_tax_solver_run.assert_post_conditions('else peculiar_status '+message)
	when 2 then
		assert_pathname_exists(CA540_example.open_tax_solver_output)
		assert_pathname_exists(CA540_example.open_tax_solver_sysout)
		CA540_example.run_open_tax_solver.assert_open_tax_solver
	else
		warn(message)
		warn('!CA540_example.open_tax_solver_run.success?='+(!CA540_example.open_tax_solver_run.success?).to_s)
	end #case
#	CA540_example.build.assert_pdf_to_jpeg
	CA540_example.build.assert_build
#	CA540_example.build.assert_build.assert_pdf_to_jpeg
end #assert_open_tax_solver
def test_assert_ots_to_json
end #assert_ots_to_json
def test_assert_json_to_fdf
end #assert_json_to_fdf
def test_assert_fdf_to_pdf
end #assert_json_to_fdf
def test_assert_pdf_to_jpeg
end #assert_json_to_fdf
def test_assert_build
	CA540_example.build.assert_build
	CA540_example.build.assert_build.assert_ots_to_json
end #build
def test_Examples
	OpenTableExplorer::Finance::TaxForm::Examples.constants.each do |e|
		value=eval(e.to_s)
		if value.instance_of?(OpenTableExplorer::Finance::TaxForm) then
			message="value=#{value.inspect}\n"
			assert_instance_of(OpenTableExplorer::Finance::TaxForm, value, message)
			assert_not_empty("../OpenTaxSolver#{Default_tax_year}_*")
			assert_not_empty(Dir["../OpenTaxSolver#{Default_tax_year}_*"], Dir["../OpenTaxSolver*"].inspect)
			assert_not_nil(Dir["../OpenTaxSolver#{Default_tax_year}_*"].sort[-1])
			assert_not_nil(value.open_tax_solver_all_form_directory, 'constant name='+e.to_s+"\n"+message)
			assert_pathname_exists(value.open_tax_solver_all_form_directory, 'constant name='+e.to_s+"\n"+"")
			assert_pathname_exists(value.open_tax_solver_form_directory, 'constant name='+e.to_s+"\n")
			assert_pathname_exists(value.open_tax_solver_input, 'constant name='+e.to_s+"\n")
			value.assert_pre_conditions('constant name='+e.to_s+"\n")
			value.assert_post_conditions('constant name='+e.to_s+"\n")
		end #if
	end #each
	assert_pathname_exists(US1040_user.open_tax_solver_input)
	assert_pathname_exists(CA540_user.open_tax_solver_input)
end #Examples
end #TaxForm
