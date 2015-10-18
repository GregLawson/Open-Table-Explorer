###########################################################################
#    Copyright (C) 2013-2015 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative '../../app/models/tax_form.rb'
require_relative '../assertions/shell_command_assertions.rb'
#require_relative '../assertions/regexp_parse_assertions.rb'
class TaxFormTest < TestCase
def model_class?
	OpenTableExplorer::Finance::TaxForm
end #model_class?
#include DefaultTests
include OpenTableExplorer::Finance::Constants
extend OpenTableExplorer::Finance::Constants
include OpenTableExplorer::Finance::TaxForm::Examples
def test_Constants
	refute_empty(OpenTaxSolver_directories, OpenTaxSolver_directories_glob)
	assert_pathname_exists(Open_Tax_Filler_Directory)
	assert_pathname_exists(IRS_pdf_directory)
end #Constants
def test_open_tax_solver_distribution_directories
	refute_empty(Dir[Downloaded_src_dir+"OpenTaxSolver#{Default_tax_year}*-*"])
	refute_empty(OpenTableExplorer::Finance::TaxForm.open_tax_solver_distribution_directories(Default_tax_year))
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
	assert_equal(OpenTableExplorer::Finance::TaxForm.ots_example_all_forms_directory, US1040_template.open_tax_solver_all_form_directory)
	assert_equal(OpenTableExplorer::Finance::TaxForm.ots_example_all_forms_directory, US1040_example.open_tax_solver_all_form_directory)
#	assert_equal(OpenTableExplorer::Finance::TaxForm.ots_example_all_forms_directory, US1040_example1.open_tax_solver_all_form_directory)
	assert_equal(OpenTableExplorer::Finance::TaxForm.ots_example_all_forms_directory, US1040_example.open_tax_solver_all_form_directory)
end # ots_example_all_forms_directory
def test_TaxForm_ots_user_all_forms_directory
	assert_equal(OpenTableExplorer::Finance::TaxForm.ots_user_all_forms_directory, US1040_user.open_tax_solver_all_form_directory)
	assert_equal(OpenTableExplorer::Finance::TaxForm.ots_user_all_forms_directory, US1040_user.open_tax_solver_all_form_directory)
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
	refute_nil(US1040_example.open_tax_solver_all_form_directory)
	tax_form = OpenTableExplorer::Finance::TaxForm.new(:example, form, jurisdiction, Default_tax_year, OpenTableExplorer::Finance::TaxForm.ots_user_all_forms_directory(@tax_year))
	assert_pathname_exists(tax_form.open_tax_solver_form_directory)
	assert_pathname_exists(US1040_template.open_tax_solver_form_directory)
	assert_pathname_exists(US1040_template.open_tax_solver_form_directory+'/'+US1040_template.taxpayer_basename_with_year+'.txt')
	assert_match(/CA_540_#{Default_tax_year}$/, US1040_example.open_tax_solver_binary)
	assert_equal('US_1040_example', US1040_example.taxpayer_basename)
#	assert_equal('US_1040_example1', US1040_example1.taxpayer_basename)
	assert_equal("CA_540_#{Default_tax_year}_example", US1040_example.taxpayer_basename)
	assert_equal("CA_540_#{Default_tax_year}_template", US1040_template.taxpayer_basename)
	refute_empty(Dir[US1040_example.output_xfdf_glob])
end #initialize
def test_example
	US1040_example.build.assert_build.assert_pdf_to_jpeg
	US1040_example.build
	US1040_example.assert_open_tax_solver
#	US1040_example.assert_ots_to_json
	US1040_example.commit_minor_change!(Dir['test/data_sources/tax_form/*/*'], 'fixup! TaxForm update timestamps')
	US1040_example.build.assert_build
	US1040_example.build.assert_build.assert_ots_to_json
#	US1040_example.assert_build
end #example
def test_user
	US1040_user.build.assert_build.assert_pdf_to_jpeg
#	US1040_user.build.assert_ots_to_json
end #user
def test_template
	US1040_template.build.assert_open_tax_solver
#	US1040_template.build.assert_ots_to_json
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
	US1040_user.run_open_tax_solver.assert_open_tax_solver
	US1040_template.run_open_tax_solver.assert_open_tax_solver
	US1040_template.run_open_tax_solver.assert_open_tax_solver
	US1040_example.run_open_tax_solver.assert_open_tax_solver
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
def test_generated_xfdf_files
	assert(!Dir[US1040_example.output_xfdf_glob].empty?, Dir[US1040_example.output_xfdf_glob].inspect)
	assert(!Dir[US1040_example.output_xfdf_glob].empty?, Dir[US1040_example.output_xfdf_glob].inspect)
	assert(!Dir[US1040_user.output_xfdf_glob].empty?, Dir[US1040_user.output_xfdf_glob].inspect)
	assert(!Dir[US1040_user.output_xfdf_glob].empty?, Dir[US1040_user.output_xfdf_glob].inspect)
	assert(!US1040_example.generated_xfdf_files.empty?, Dir[US1040_example.output_xfdf_glob].inspect)
	assert(!US1040_example.generated_xfdf_files.empty?, Dir[US1040_example.output_xfdf_glob].inspect)
	assert(!US1040_user.generated_xfdf_files.empty?, Dir[US1040_user.output_xfdf_glob].inspect)
	assert(!US1040_user.generated_xfdf_files.empty?, Dir[US1040_user.output_xfdf_glob].inspect)
	assert_instance_of(Array, US1040_example.generated_xfdf_files)
	US1040_example.generated_xfdf_files.each do |xdf_capture|
		assert_kind_of(Capture, xdf_capture, US1040_example.generated_xfdf_files)
	end # each
end # generated_xfdf_files
def test_run_fdf_to_pdf
	US1040_user.generated_xfdf_files.map do |xdf_capture|
		matching_pdf_filename = 'f' + xdf_capture.output?[:form].to_s  + xdf_capture.output?[:form_suffix].to_s + '--' + Default_tax_year.to_s+ '.pdf'
		matching_pdf_file = IRS_pdf_directory + matching_pdf_filename
		assert(File.exist?(matching_pdf_file), matching_pdf_file + "\n" + xdf_capture.inspect)
		matching_pdf_filled_in_file = IRS_pdf_directory + matching_pdf_filename
		assert(File.exist?(matching_pdf_file), matching_pdf_file + "\n" + xdf_capture.inspect)
	end # each
	US1040_user.run_fdf_to_pdf.assert_fdf_to_pdf
	US1040_user.run_fdf_to_pdf.assert_fdf_to_pdf
end # run_fdf_to_pdf
def test_filled_in_pdf_files
	assert(!US1040_example.filled_in_pdf_files.empty?, Dir[US1040_example.output_xfdf_glob].inspect)
	assert(!US1040_example.filled_in_pdf_files.empty?, Dir[US1040_example.output_xfdf_glob].inspect)
	assert(!US1040_user.filled_in_pdf_files.empty?, Dir[US1040_user.output_xfdf_glob].inspect)
	assert(!US1040_user.filled_in_pdf_files.empty?, Dir[US1040_user.output_xfdf_glob].inspect)
	US1040_user.filled_in_pdf_files.each do |filled_in_pdf_file|
#		assert(File.exist?(filled_in_pdf_file), filled_in_pdf_file.inspect)
		pid = Process.fork {ShellCommands.new('evince ' + filled_in_pdf_file).assert_pre_conditions}
		Process.detach(pid)
	end # each
	US1040_user.filled_in_pdf_files.each do |filled_in_pdf_file|
		assert(File.exist?(filled_in_pdf_file), filled_in_pdf_file + US1040_user.generated_xfdf_files.inspect)
		ShellCommands.new('evince ' + filled_in_pdf_file).assert_pre_conditions
	end # each
end # filled_in_pdf_files
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
	US1040_example.build
	refute_nil(US1040_example.open_tax_solver_run, US1040_example.inspect)
	refute_nil(US1040_example.open_tax_solver_run.process_status, US1040_example.inspect)
	peculiar_status=US1040_example.open_tax_solver_run.process_status.exitstatus
	if File.exists?(US1040_example.open_tax_solver_sysout) then
		message=IO.binread(US1040_example.open_tax_solver_sysout)
	else
		message="file=#{US1040_example.open_tax_solver_sysout} does not exist"
	end #if
	message+=US1040_example.open_tax_solver_run.errors
	US1040_example.open_tax_solver_run.puts if $VERBOSE
	puts "peculiar_status=#{peculiar_status}" if $VERBOSE
	puts "message='#{message}'" if $VERBOSE
	case peculiar_status
	when 0 then 
		US1040_example.open_tax_solver_run.assert_post_conditions('else peculiar_status '+message)
	when 1 then
		# fed not found
		message+="\nfed input not found"
		message+="\nUS1040_example.open_tax_solver_output=#{US1040_example.open_tax_solver_output}\n"
#		US1040_example.open_tax_solver_run.assert_post_conditions('peculiar_status == 1 '+message)
	when 2 then
		assert_pathname_exists(US1040_example.open_tax_solver_output)
		assert_pathname_exists(US1040_example.open_tax_solver_sysout)
		US1040_example.run_open_tax_solver.assert_open_tax_solver
	else
		warn(message)
		warn('!US1040_example.open_tax_solver_run.success?='+(!US1040_example.open_tax_solver_run.success?).to_s)
	end #case
#	US1040_example.build.assert_pdf_to_jpeg
	US1040_example.build.assert_build
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
	US1040_example.build.assert_build
#	CA540_example.build.assert_build.assert_ots_to_json
end #build
def test_Examples
	OpenTableExplorer::Finance::TaxForm::Examples.constants.each do |e|
		value=eval(e.to_s)
		if value.instance_of?(OpenTableExplorer::Finance::TaxForm) then
			message="value=#{value.inspect}\n"
			assert_instance_of(OpenTableExplorer::Finance::TaxForm, value, message)
			refute_empty("../OpenTaxSolver#{Default_tax_year}_*")
			refute_empty(Dir["../OpenTaxSolver#{Default_tax_year}_*"], Dir["../OpenTaxSolver*"].inspect)
			refute_nil(Dir["../OpenTaxSolver#{Default_tax_year}_*"].sort[-1])
			refute_nil(value.open_tax_solver_all_form_directory, 'constant name='+e.to_s+"\n"+message)
			assert_pathname_exists(value.open_tax_solver_all_form_directory, 'constant name='+e.to_s+"\n"+"")
			assert_pathname_exists(value.open_tax_solver_form_directory, 'constant name='+e.to_s+"\n")
			assert_pathname_exists(value.open_tax_solver_input, 'constant name='+e.to_s+"\n")
			value.assert_pre_conditions('constant name='+e.to_s+"\n")
			value.assert_post_conditions('constant name='+e.to_s+"\n")
		end #if
	end #each
	assert_pathname_exists(US1040_user.open_tax_solver_input)
	assert_pathname_exists(US1040_user.open_tax_solver_input)
end #Examples
end #TaxForm
