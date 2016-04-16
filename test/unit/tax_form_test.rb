###########################################################################
#    Copyright (C) 2011-2016 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../../app/models/test_environment_test_unit.rb'
#require_relative 'test_environment'
require_relative '../../app/models/tax_form.rb'
require_relative '../assertions/ruby_assertions_test_unit.rb'
class OtsRunTest < TestCase
include RubyAssertions
def model_class?
	OpenTableExplorer::Finance::OtsRun
end #model_class?
#include DefaultTests
include OpenTableExplorer # for FileIPO
include OpenTableExplorer::Finance
include OpenTableExplorer::Finance::DefinitionalConstants
extend OpenTableExplorer::Finance::DefinitionalConstants
include OpenTableExplorer::Finance::OtsRun::Examples
include OpenTableExplorer::Finance::TaxpayerSchedule::Examples
#US1040_example_schedule = 	OpenTableExplorer::Finance::TaxpayerSchedule.new(ots: OpenTableExplorer::Finance::OtsRun::Examples::US1040_example.build, '', '')
US1040_example_schedule = 	TaxpayerSchedule.new(ots: OtsRun::Examples::US1040_example, form_prefix: 'f', form_suffix: '')
def test_Finance_DefinitionalConstants
	refute_empty(OpenTaxSolver_directories, OpenTaxSolver_directories_glob)
	assert_pathname_exists(Open_Tax_Filler_Directory)
	assert_pathname_exists(IRS_pdf_directory)
end # DefinitionalConstants
def test_Filing_to_s
	assert_equal('ng', Filing.to_s)
	assert_equal('US', Filing::US.to_s)
end # to_s
def test_form_filename
	assert_equal('US_1040', Filing::US.form_filename)
end # form_filename
def test_Filing_jurisdiction
	assert_equal(Filing::US, Filing::US.jurisdiction)
end # jurisdiction
def test_download
	tax_form_examples = Filing::Tax_form_examples.select do |example|
#		example[:jurisdiction] == @filing.jurisdiction.to_s && example[:form] == @filing.form.to_s
	end # each
#	xfdf_script_filename = @filing.jurisdiction.to_s + '_' + @filing.form + '_' + @filing.tax_year.to_s
end # download
def test_run_fdf_to_pdf
	US1040_user.cached_schedules.map do |xdf_schedule|
		matching_pdf_filename = 'f' + xdf_schedule.ots.filing.jurisdiction.base_form.to_s  + xdf_schedule.form_suffix.to_s + '--' + Default_tax_year.to_s+ '.pdf'
		matching_pdf_file = IRS_pdf_directory + matching_pdf_filename
		assert(File.exist?(matching_pdf_file), matching_pdf_file + "\n" + xdf_schedule.inspect)
		matching_pdf_filled_in_file = IRS_pdf_directory + matching_pdf_filename
		assert(File.exist?(matching_pdf_file), matching_pdf_file + "\n" + xdf_schedule.inspect)
		xdf_schedule.cached_fdf_to_pdf_run #.assert_fdf_to_pdf
	end # each
end # Run_fdf_to_pdf_default
def 	test_run_pdf_to_jpeg
	US1040_user.cached_schedules.map do |xdf_schedule|
	#	refute_nil(xdf_schedule.output_pdf, xdf_schedule.inspect)
		refute_nil(xdf_schedule.output_pdf)
		output_pdf_pathname = Pathname.new(File.expand_path(xdf_schedule.output_pdf))
		assert_instance_of(Pathname, output_pdf_pathname)
		cleanpath_name=output_pdf_pathname.cleanpath
		clean_directory=Pathname.new(File.expand_path(xdf_schedule.ots.open_tax_solver_form_directory)).cleanpath
		output_pdf=cleanpath_name.relative_path_from(clean_directory)
#		US1040_example.assert_pdf_to_jpeg
	#	US1040_template.run_pdf_to_jpeg.assert_pdf_to_jpeg
	#	US1040_example.run_pdf_to_jpeg.assert_pdf_to_jpeg
	#	CA540_template.run_pdf_to_jpeg.assert_pdf_to_jpeg
	#	CA540_example.run_pdf_to_jpeg.assert_pdf_to_jpeg
	#	US1040_user.run_pdf_to_jpeg.assert_pdf_to_jpeg
	#	CA540_user.run_pdf_to_jpeg.assert_pdf_to_jpeg
	end # each
end # Run_pdf_to_jpeg_default
def test_schedule_name
	assert_equal('f1040', US1040_example_schedule.schedule_name)
end # schedule_name
def test_base_path
end # base_path
def test_xfdf_file
	assert_equal('.xfdf', US1040_example_schedule.xfdf_file[-5..-1])
end # xfdf_file
def test_output_pdf
	assert(File.exist?(US1040_example_schedule.ots.open_tax_solver_form_directory), US1040_example_schedule.ots.open_tax_solver_form_directory)
	assert(File.exist?(US1040_example_schedule.output_pdf), US1040_example_schedule.output_pdf)
end # output_pdf
def test_fillout_form
	assert(File.exist?(US1040_example_schedule.fillout_form), US1040_example_schedule.fillout_form)
end # fillout_form
def test_Ots_run_default
	open_tax_solver_run = Ots_run_default.call(US1040_template, nil)
	open_tax_solver_errors = US1040_template.open_tax_solver_errors(open_tax_solver_run)
	assert_instance_of(Hash, open_tax_solver_errors)
#	assert_instance_of(Process::Status, open_tax_solver_errors[:process_status])
	assert_instance_of(Fixnum, open_tax_solver_errors[:exitstatus])
	assert_equal(1, US1040_template.open_tax_solver_errors[:exitstatus], open_tax_solver_errors.inspect)
	ots_run_default = Ots_run_default.call(US1040_example, nil)
	assert_equal(0, Ots_run_default.call(US1040_example, nil).errors[:exitstatus])
	assert_equal(0, Ots_run_default.call(US1040_user, nil).errors[:exitstatus], US1040_user.open_tax_solver_errors.inspect)
	assert_equal(0, Ots_run_default.call(CA540_user, nil).errors[:exitstatus], CA540_user.open_tax_solver_errors.inspect)
	assert_equal(0, Ots_run_default.call(US1040_example, nil).errors[:exitstatus], US1040_example.explain_open_tax_solver)
	assert_equal(0, Ots_run_default.call(CA540_example, nil).errors[:exitstatus], CA540_example.open_tax_solver_errors.inspect)
	assert_equal(1, Ots_run_default.call(US1040_template, nil).errors[:exitstatus], US1040_template.open_tax_solver_errors.inspect)
	assert_equal(1, Ots_run_default.call(CA540_template, nil).errors[:exitstatus], CA540_template.open_tax_solver_errors.inspect)
end # Ots_run_default
def test_Run_ots_to_fdf_default
	assert_equal(0, Run_ots_to_fdf_default.call(US1040_user, nil).errors[:exitstatus])
	assert_equal(0, Run_ots_to_fdf_default.call(CA540_user, nil).errors[:exitstatus])
	assert_equal(0, Run_ots_to_fdf_default.call(US1040_example, nil).errors[:exitstatus])
	assert_equal(0, Run_ots_to_fdf_default.call(CA540_example, nil).errors[:exitstatus])
	assert_equal(0, Run_ots_to_fdf_default.call(US1040_template, nil).errors[:exitstatus])
	assert_equal(0, Run_ots_to_fdf_default.call(CA540_template, nil).errors[:exitstatus])
end # run_ots_to_fdf
def test_Generated_xfdf_files_default
	assert_empty(Generated_xfdf_files_default.call(US1040_template, nil), US1040_template.inspect)
	assert_empty(Generated_xfdf_files_default.call(CA540_template, nil), US1040_template.inspect)
	refute_empty(Generated_xfdf_files_default.call(US1040_example, nil), US1040_template.inspect)
	refute_empty(Generated_xfdf_files_default.call(US1040_user, nil), US1040_template.inspect)
	refute_empty(Generated_xfdf_files_default.call(CA540_user, nil), US1040_template.inspect)
	refute_empty(Generated_xfdf_files_default.call(CA540_example, nil), US1040_template.inspect)
	ots = US1040_example
	Generated_xfdf_files_default.call(US1040_example, nil).each do |schedule|
		TaxpayerSchedule.new(ots: schedule.ots, form_prefix: schedule.form_prefix, form_suffix: schedule.form_suffix)		
	end # each
end # generated_xfdf_files
def test_Errors_default
	ots = US1040_example
	errors = {}
	errors[:open_tax_solver] = ots.open_tax_solver_errors(ots.cached_open_tax_solver_run)
	errors[:run_ots_to_fdf] = ots.cached_run_ots_to_fdf.errors
	refute_empty(ots.cached_schedules, ots.inspect)
	errors[:schedules] = Generated_xfdf_files_default.call(ots, nil).map do |schedule| 
		{schedule => TaxpayerSchedule::Run_pdf_to_jpeg_default.call(schedule, nil).errors}
	end # map
#	errors[:schedules] = ots.cached_schedules.map {|schedule| {schedule => schedule.cached_pdf_to_jpeg_run.errors} }
	errors_default = Errors_default.call(ots, nil)
	errors = ots.open_tax_solver_errors
	assert_equal(errors_default, errors)
end # Errors_default
def test_open_tax_solver_distribution_directories
	refute_empty(Dir[Downloaded_src_dir+"OpenTaxSolver#{Default_tax_year}*-*"])
	refute_empty(OpenTableExplorer::Finance::OtsRun.open_tax_solver_distribution_directories(Default_tax_year))
	assert_pathname_exists(OTS_example_directories, 'mkdir test/data_sources/tax_form')
end # open_tax_solver_distribution_directories
def test_OtsRun_open_tax_solver_distribution_directory
	assert_pathname_exists(OpenTableExplorer::Finance::OtsRun.open_tax_solver_distribution_directory(Default_tax_year))
end # open_tax_solver_distribution_directory
def test_OtsRun_ots_example_all_forms_directory
	assert_pathname_exists(OTS_example_directories.to_s, OTS_example_directories.inspect)
	assert_pathname_exists(OTS_example_directories.to_s + '/' + Default_tax_year.to_s, OTS_example_directories.inspect)
	assert_pathname_exists(OTS_example_directories.to_s + '/' + Default_tax_year.to_s + '/examples_and_templates', OTS_example_directories.inspect)
	assert_pathname_exists(OTS_example_directories.to_s + '/' + Default_tax_year.to_s + '/examples_and_templates/', OTS_example_directories.inspect)
	assert_equal(OTS_example_directories.to_s + '/' + Default_tax_year.to_s + '/examples_and_templates/', OpenTableExplorer::Finance::OtsRun.ots_example_all_forms_directory.to_s)
	path_string = OTS_example_directories.to_s + '/' + Default_tax_year.to_s + '/examples_and_templates/'
	assert_pathname_exists(path_string, path_string.inspect)
	assert_pathname_exists(Pathname.new(path_string).expand_path)
	assert_pathname_exists(OpenTableExplorer::Finance::OtsRun.ots_example_all_forms_directory)
	assert_equal(OpenTableExplorer::Finance::OtsRun.ots_example_all_forms_directory, CA540_template.open_tax_solver_all_form_directory)
	assert_equal(OpenTableExplorer::Finance::OtsRun.ots_example_all_forms_directory, US1040_example.open_tax_solver_all_form_directory)
#	assert_equal(OpenTableExplorer::Finance::OtsRun.ots_example_all_forms_directory, US1040_example1.open_tax_solver_all_form_directory)
	assert_equal(OpenTableExplorer::Finance::OtsRun.ots_example_all_forms_directory, CA540_example.open_tax_solver_all_form_directory)
end # ots_example_all_forms_directory
def test_OtsRun_ots_user_all_forms_directory
	assert_equal(OpenTableExplorer::Finance::OtsRun.ots_user_all_forms_directory, US1040_user.open_tax_solver_all_form_directory)
	assert_equal(OpenTableExplorer::Finance::OtsRun.ots_user_all_forms_directory, CA540_user.open_tax_solver_all_form_directory)
	assert_pathname_exists(OpenTableExplorer::Finance::OtsRun.ots_user_all_forms_directory(@tax_year)+"/#{@filing.jurisdiction.form_filename}/")
end # ots_user_all_forms_directory
def test_logical_primary_key
#	assert_equal([], US1040_user.attribute_set, US1040_user.inspect)
end # logical_primary_key
def test_open_tax_solver_distribution_directory
	assert_pathname_exists(US1040_template.open_tax_solver_distribution_directory)
end # open_tax_solver_distribution_directory
def test_OtsRun_virtus
#	sysout=`#{Command}`
#	puts "test_run_tax_solver sysout=#{sysout}"
	assert_equal('1040', US1040_template.filing.jurisdiction.base_form)
	assert_equal('1040', US1040_example.filing.jurisdiction.base_form)
	assert_equal('1040', US1040_user.filing.jurisdiction.base_form)
	assert_equal(Filing::US, US1040_template.filing.jurisdiction)
	assert_equal(Filing::US, US1040_example.filing.jurisdiction)
	assert_equal(Filing::US, US1040_user.filing.jurisdiction)
	assert_pathname_exists(US1040_example.open_tax_solver_all_form_directory)
	refute_nil(US1040_example.open_tax_solver_all_form_directory)
end # values
def test_open_tax_solver_form_directory 
	form='1040'
	filing = US_current_year
	tax_form = OpenTableExplorer::Finance::OtsRun.new(taxpayer: :example, base_form: form, filing: filing, tax_year: Default_tax_year, open_tax_solver_all_form_directory: OpenTableExplorer::Finance::OtsRun.ots_user_all_forms_directory(@tax_year))
	assert_pathname_exists(tax_form.open_tax_solver_form_directory)
	assert_pathname_exists(US1040_template.open_tax_solver_form_directory)
	assert_pathname_exists(Simplified_example.open_tax_solver_all_form_directory)
	assert_equal(Filing::US, Simplified_example.filing.jurisdiction)
	assert_equal('US', Simplified_example.filing.jurisdiction.to_s)
	assert_equal('US_1040', Simplified_example.filing.jurisdiction.form_filename)
	assert_pathname_exists(Simplified_example.open_tax_solver_all_form_directory + Simplified_example.filing.jurisdiction.form_filename)
	assert_pathname_exists(Simplified_example.open_tax_solver_form_directory)
end #open_tax_solver_form_directory 
def test_open_tax_solver_chdir
end # open_tax_solver_chdir
def test_taxpayer_basename_with_year
	assert_equal('US_1040', US1040_user.filing.jurisdiction.form_filename)
	assert_equal('2014', US1040_user.tax_year.to_s)
	assert_equal('greg', US1040_user.taxpayer)

end # taxpayer_basename_with_year
def test_taxpayer_basename 
	assert_pathname_exists(CA540_template.open_tax_solver_form_directory+'/'+CA540_template.taxpayer_basename_with_year+'.txt')
	assert_equal('US_1040_example', US1040_example.taxpayer_basename)
#	assert_equal('US_1040_example1', US1040_example1.taxpayer_basename)
	assert_equal("CA_540_#{Default_tax_year}_example", CA540_example.taxpayer_basename)
	assert_equal("CA_540_#{Default_tax_year}_template", CA540_template.taxpayer_basename)
end # taxpayer_basename 
def test_open_tax_solver_binary
	assert_match(/CA_540_#{Default_tax_year}$/, CA540_example.open_tax_solver_binary)
end # open_tax_solver_binary
def test_output_xfdf_glob 
	refute_empty(Dir[US1040_example.output_xfdf_glob])
	refute_empty(Dir[CA540_example.output_xfdf_glob])
	refute_empty(Dir[US1040_user.output_xfdf_glob])
	refute_empty(Dir[CA540_user.output_xfdf_glob])
	assert_empty(Dir[US1040_template.output_xfdf_glob])
	assert_empty(Dir[CA540_template.output_xfdf_glob])
end # output_xfdf_glob 
def test_generated_xfdf_files_regexp
	assert(!Dir[US1040_example.output_xfdf_glob].empty?, Dir[US1040_example.output_xfdf_glob].inspect)
	assert(!Dir[CA540_example.output_xfdf_glob].empty?, Dir[CA540_example.output_xfdf_glob].inspect)
	assert(!Dir[US1040_user.output_xfdf_glob].empty?, Dir[US1040_user.output_xfdf_glob].inspect)
	assert(!Dir[CA540_user.output_xfdf_glob].empty?, Dir[CA540_user.output_xfdf_glob].inspect)
	assert(!US1040_example.cached_schedules.empty?, Dir[US1040_example.output_xfdf_glob].inspect)
	assert(!CA540_example.cached_schedules.empty?, Dir[CA540_example.output_xfdf_glob].inspect)
	assert(!US1040_user.cached_schedules.empty?, Dir[US1040_user.output_xfdf_glob].inspect)
	assert(!CA540_user.cached_schedules.empty?, Dir[CA540_user.output_xfdf_glob].inspect)
	assert_instance_of(Array, US1040_example.cached_schedules)
	xfdf_file_pattern = US1040_example.generated_xfdf_files_regexp()
	Dir[US1040_example.output_xfdf_glob].map do |xfdf_file|
		xdf_capture = xfdf_file.capture?(xfdf_file_pattern)
		schedule = TaxpayerSchedule.new(ots: US1040_example, form_prefix: xdf_capture.output?[:form_prefix], form_suffix: xdf_capture.output?[:form_suffix])
		assert_equal('f', schedule.form_prefix)
#		schedule.ots.
		assert_equal(xfdf_file, schedule.xfdf_file, schedule.inspect)
	end # map
	US1040_example.cached_schedules.map do |xdf_schedule|
		assert_kind_of(TaxpayerSchedule, xdf_schedule, US1040_example.cached_schedules.inspect)
	end # each
end # generated_xfdf_files_regexp
def test_compact_message
end # compact_message
def test_open_tax_solver_errors
	open_tax_solver_run = Ots_run_default.call(US1040_template, nil)
	open_tax_solver_errors = US1040_template.open_tax_solver_errors(open_tax_solver_run)
	assert_instance_of(Hash, open_tax_solver_errors)
#	assert_instance_of(Process::Status, open_tax_solver_errors[:process_status])
	assert_instance_of(Fixnum, open_tax_solver_errors[:exitstatus])
	assert_equal(1, open_tax_solver_run.errors[:exitstatus], open_tax_solver_errors)
	assert_equal(1, open_tax_solver_run.errors[:exitstatus], open_tax_solver_errors.inspect)
	assert_equal(1, US1040_template.open_tax_solver_errors[:exitstatus], open_tax_solver_errors.inspect)
	assert_equal(0, US1040_user.open_tax_solver_errors[:exitstatus], US1040_user.open_tax_solver_errors.inspect)
	assert_equal(0, CA540_user.open_tax_solver_errors[:exitstatus], CA540_user.open_tax_solver_errors.inspect)
	assert_equal(0, US1040_example.open_tax_solver_errors[:exitstatus], US1040_example.explain_open_tax_solver)
	assert_equal(0, CA540_example.open_tax_solver_errors[:exitstatus], CA540_example.open_tax_solver_errors.inspect)
	assert_equal(1, US1040_template.open_tax_solver_errors[:exitstatus], US1040_template.open_tax_solver_errors.inspect)
	assert_equal(1, CA540_template.open_tax_solver_errors[:exitstatus], CA540_template.open_tax_solver_errors.inspect)
	assert_operator(0, :<, US1040_template.open_tax_solver_errors[:ots_errors].size, US1040_template.open_tax_solver_errors)
	open_tax_solver_errors = CA540_template.open_tax_solver_errors
	assert_instance_of(Hash, open_tax_solver_errors)
	assert_instance_of(Array, open_tax_solver_errors[:ots_errors], open_tax_solver_errors)
	assert_operator(0, :<, open_tax_solver_errors[:ots_errors].size, open_tax_solver_errors)
	assert_instance_of(Hash, open_tax_solver_errors[:ots_errors].first, open_tax_solver_errors)
	assert_instance_of(String, open_tax_solver_errors[:ots_errors].first[:string_argument], open_tax_solver_errors)
	expected_file = open_tax_solver_errors[:ots_errors].first[:string_argument]
	refute_equal(US1040_template.open_tax_solver_output, CA540_template.open_tax_solver_chdir + expected_file, CA540_template.explain_open_tax_solver)
end # open_tax_solver_errors
def test_explain_open_tax_solver
	assert_match(/Writing\ results\ to\ file: /, US1040_user.explain_open_tax_solver, US1040_user.explain_open_tax_solver)
	assert_match(/Writing results to file: /, CA540_user.explain_open_tax_solver, CA540_user.explain_open_tax_solver)
	assert_match(/Writing results to file: /, US1040_example.explain_open_tax_solver, US1040_user.explain_open_tax_solver)
	assert_match(/Writing results to file: /, CA540_example.explain_open_tax_solver, CA540_example.explain_open_tax_solver)
	assert_match(/Error: unrecognized status \'\?\?'. Exiting./, US1040_template.explain_open_tax_solver, US1040_template.explain_open_tax_solver)
	assert_match(/Error: Could not open Federal return /, CA540_template.explain_open_tax_solver, CA540_template.explain_open_tax_solver)
end # explain_open_tax_solver
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
# Assertions custom instance methods
def test_assert_open_tax_solver
	US1040_user.assert_open_tax_solver
	CA540_user.assert_open_tax_solver
	US1040_example.assert_open_tax_solver
	CA540_example.assert_open_tax_solver
	assert_raises(AssertionFailedError) {US1040_template.assert_open_tax_solver}
	assert_raises(AssertionFailedError) {CA540_template.assert_open_tax_solver}
#	CA540_example
	refute_nil(CA540_example.cached_open_tax_solver_run, CA540_example.inspect)
	if File.exists?(CA540_example.open_tax_solver_sysout) then
		message=IO.binread(CA540_example.open_tax_solver_sysout)
	else
		message="file=#{CA540_example.open_tax_solver_sysout} does not exist"
	end #if
	message+=CA540_example.cached_open_tax_solver_run.errors.inspect
	CA540_example.cached_open_tax_solver_run.puts if $VERBOSE
	puts "message='#{message}'" if $VERBOSE
#	CA540_example.assert_pdf_to_jpeg
end #assert_open_tax_solver
def test_assert_ots_to_json
end #assert_ots_to_json
def test_assert_json_to_fdf
end #assert_json_to_fdf
def test_assert_fdf_to_pdf
end #assert_json_to_fdf
def test_assert_pdf_to_jpeg
end #assert_json_to_fdf
def test_Examples
	OpenTableExplorer::Finance::OtsRun::Examples.constants.each do |e|
		value=eval(e.to_s)
		if value.instance_of?(OpenTableExplorer::Finance::OtsRun) then
			message="value=#{value.inspect}\n"
			assert_instance_of(OpenTableExplorer::Finance::OtsRun, value, message)
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
	assert_pathname_exists(CA540_user.open_tax_solver_input)
	us1040_example = OpenTableExplorer::Finance::OtsRun.new(cached_open_tax_solver_run: Pwd, cached_run_ots_to_fdf: Pwd,
			taxpayer: Example, filing: US_current_year, tax_year: Default_tax_year, open_tax_solver_all_form_directory: OtsRun.ots_example_all_forms_directory)
#	us1040_example = OpenTableExplorer::Finance::OtsRun.new(taxpayer: :example, form: '1040', jurisdiction: US, tax_year: Default_tax_year, open_tax_solver_all_form_directory: OtsRun.ots_example_all_forms_directory)
end #Examples

#def test_run_ots_to_json
#	assert_pathname_exists(Open_Tax_Filler_Directory)
#	open_tax_form_filler_ots_js="#{Open_Tax_Filler_Directory}/script/json_ots.js"
#	assert_pathname_exists(open_tax_form_filler_ots_js)
#	US1040_template.run_ots_to_json.ots_to_json_run.assert_post_conditions
#	US1040_example.run_ots_to_json.ots_to_json_run.assert_post_conditions
#	CA540_template.run_ots_to_json.ots_to_json_run.assert_post_conditions
#	CA540_example.run_ots_to_json.ots_to_json_run.assert_post_conditions
#	OpenTableExplorer::Finance::OtsRun.new(taxpayer: :example, filing: :US_current_year, open_tax_solver_all_form_directory: ).run_ots_to_json
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
def test_run_ots_to_json
end #run_ots_to_json
def test_run_json_to_fdf
end #run_json_to_fdf
def test_new_from_path
end # new_from_path
def test_TaxpayerSchedule_initialize
	assert_equal('', US1040_example_schedule.form_suffix)
	assert_equal('1040', US1040_example_schedule.ots.filing.jurisdiction.base_form)
	assert_equal('f', US1040_example_schedule.form_prefix)
end # initialize
def test_filled_in_pdf_files
#	assert(!US1040_example.filled_in_pdf_files.empty?, Dir[US1040_example.output_xfdf_glob].inspect)
#	assert(!CA540_example.filled_in_pdf_files.empty?, Dir[CA540_example.output_xfdf_glob].inspect)
#	assert(!US1040_user.filled_in_pdf_files.empty?, Dir[US1040_user.output_xfdf_glob].inspect)
#	assert(!CA540_user.filled_in_pdf_files.empty?, Dir[CA540_user.output_xfdf_glob].inspect)
#	US1040_user.filled_in_pdf_files.each do |filled_in_pdf_file|
#		assert(File.exist?(filled_in_pdf_file), filled_in_pdf_file.inspect)
#		ShellCommands.new('evince ' + filled_in_pdf_file).assert_pre_conditions
#	end # each
#	CA540_user.filled_in_pdf_files.each do |filled_in_pdf_file|
#		assert(File.exist?(filled_in_pdf_file), filled_in_pdf_file + CA540_user.cached_schedules.inspect)
#		ShellCommands.new('evince ' + filled_in_pdf_file).assert_pre_conditions
#	end # each
end # filled_in_pdf_files
end #OtsRun
