###########################################################################
#    Copyright (C) 2011-2017 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../../app/models/test_environment_test_unit.rb'
# require_relative 'test_environment'
require_relative '../../app/models/tax_form.rb'
require_relative '../../app/models/branch.rb'

		class TestClass
		end # TestClass

class FinanceTest < TestCase
  include RubyAssertions
  # include DefaultTests
  include OpenTableExplorer::Finance
  include OpenTableExplorer::Finance::DefinitionalConstants
  extend OpenTableExplorer::Finance::DefinitionalConstants
  include OpenTableExplorer::Finance::OtsRun::Examples
  include OpenTableExplorer::Finance::OtsTaxpayerSchedule::Examples

	def test_clone_state
		hidden_clone_answer = [[{{:dup=>:hash}=>true},
  {{:dup=>:inspect}=>true},
  {{:dup=>:object_id}=>false}],
 [{{:clone=>:hash}=>true},
  {{:clone=>:inspect}=>true},
  {{:clone=>:object_id}=>false}]]
		assert_equal(hidden_clone_answer, 'a'.clone_state)
		assert_equal(hidden_clone_answer, CA_current_year.clone_state)
#!		assert_equal(hidden_clone_answer, TestClass.new.freeze.clone_state)
#!		assert_equal(hidden_clone_answer, TestClass.new.clone_state)
	end # clone_state
	
	def test_assert_clone_state
		'a'.assert_clone_state
		CA_current_year.assert_clone_state
		TestClass.new.freeze.assert_clone_state
		TestClass.new.assert_clone_state
		US1040_user.assert_clone_state
	end # assert_clone_state

	def test_clone_explain
		assert_equal('', 'a'.clone_explain)
	end # clone_explain
	
	def test_cache
#		object = TestClass.new.freeze
		object = CA_current_year
#!		object = object.clone
		cache_name = :test
		assert_raise(RuntimeError) { object.cache(:test)}
#!		block = 
		cache_const_name = ('Cached_' + cache_name.to_s).to_sym
		assert_equal(:Cached_test, cache_const_name)
		refute(object.class.const_defined?(cache_const_name))
		ret = 2
		refute(object.class.const_defined?(cache_const_name))
		object.class.const_set(cache_const_name, ret)
		assert(object.class.const_defined?(cache_const_name))
		assert_equal(2, object.class.const_get(cache_const_name))
		refute_nil(object.cache(:test){|| 2}, object.inspect)
		assert_equal(2, object.cache(:test){|| 2})
		assert_equal(2, object.class.const_get(cache_const_name), object.class.const_get(cache_const_name))
	end # cache



  def test_Finance_DefinitionalConstants
    refute_empty(OpenTaxSolver_directories, OpenTaxSolver_directories_glob)
    assert_pathname_exists(Open_Tax_Filler_Directory)
    assert_pathname_exists(IRS_pdf_directory)
#!		assert_equal(This_year - 1, Default_tax_year)
  end # Finance_DefinitionalConstants
end # Finance

require_relative '../../app/models/assertions.rb'
    class Filing < Dry::Types::Value
	module Assertions
    module ClassMethods
        def assert_pre_conditions(message = '')
          message += "\nIn assert_pre_conditions, self=#{inspect}"
#!          RubyAssertions.assert_directory_exists(open_tax_solver_distribution_directory, message)
#!					assert_pathname_exists(open_tax_solver_binary, message)
#!					assert(File.exist?(open_tax_solver_distribution_directory), message)
					assert(File.exist?(open_tax_solver_binary), message)
        end # assert_pre_conditions
		end #ClassMethods
        def assert_pre_conditions(message = '')
          message += "\nIn assert_pre_conditions, self=#{inspect}"
#!          RubyAssertions.assert_directory_exists(open_tax_solver_distribution_directory, message)
#!					assert_pathname_exists(open_tax_solver_binary, message)
#!					assert(File.exist?(open_tax_solver_distribution_directory), message)
					assert(File.exist?(open_tax_solver_binary), message)
        end # assert_pre_conditions
  end # Assertions
	end # Filing
  include Assertions
  extend Assertions::ClassMethods

class FilingTest < TestCase
  include OpenTableExplorer::Finance
  include OpenTableExplorer::Finance::DefinitionalConstants
  extend OpenTableExplorer::Finance::DefinitionalConstants
  include OpenTableExplorer::Finance::OtsRun::Examples
  include OpenTableExplorer::Finance::OtsTaxpayerSchedule::Examples
  include RubyAssertions
  def test_Filing_DefinitionalConstants # constant parameters of the type (suggest all CAPS)
  end # DefinitionalConstants

  def test_Filing_to_s
    assert_equal('ng', Filing.to_s)
    assert_equal('US', Filing::US.to_s)
  end # to_s

  def test_ots_form_filename
    assert_equal('US_1040', Filing::US.ots_form_filename)
  end # ots_form_filename

  def test_Filing_jurisdiction
    assert_equal(Filing::US, Filing::US.jurisdiction)
  end # jurisdiction

  def test_open_tax_solver_distribution_directories
    refute_empty(Dir[Downloaded_src_dir + "OpenTaxSolver#{Default_tax_year}*-*"])
    refute_empty(Filing.open_tax_solver_distribution_directories(Default_tax_year))
    assert_pathname_exists(OTS_example_directories, 'mkdir test/data_sources/tax_form')
  end # open_tax_solver_distribution_directories

  def test_OtsRun_open_tax_solver_distribution_directory
    assert_pathname_exists(Filing.open_tax_solver_distribution_directory(Default_tax_year))
  end # open_tax_solver_distribution_directory

  def test_OtsRun_ots_example_all_forms_directory
    assert_pathname_exists(OTS_example_directories.to_s, OTS_example_directories.inspect)
    assert_pathname_exists(OTS_example_directories.to_s + '/' + Default_tax_year.to_s, OTS_example_directories.inspect)
    assert_pathname_exists(OTS_example_directories.to_s + '/' + Default_tax_year.to_s + '/examples_and_templates', OTS_example_directories.inspect)
    assert_equal(OTS_example_directories.to_s + '/' + Default_tax_year.to_s + '/examples_and_templates/', Filing.ots_example_all_forms_directory.to_s)
    path_string = OTS_example_directories.to_s + '/' + Default_tax_year.to_s + '/examples_and_templates/'
    assert_pathname_exists(path_string, path_string.inspect)
    assert_pathname_exists(Pathname.new(path_string).expand_path)
    assert_pathname_exists(Filing.ots_example_all_forms_directory)
    assert_equal(Filing::CA.ots_example_all_forms_directory, CA540_template.taxpayer.open_tax_solver_all_form_directory)
    assert_equal(Filing::US.ots_example_all_forms_directory, US1040_example.taxpayer.open_tax_solver_all_form_directory)
    assert_equal(Filing::CA.ots_example_all_forms_directory, CA540_example.taxpayer.open_tax_solver_all_form_directory)
  end # ots_example_all_forms_directory

  def test_Filing_ots_user_all_forms_directory
    assert_equal(Filing::US.ots_user_all_forms_directory, US1040_user.taxpayer.open_tax_solver_all_form_directory)
    assert_equal(Filing::US.ots_user_all_forms_directory, CA540_user.taxpayer.open_tax_solver_all_form_directory)
    assert_pathname_exists(Filing.ots_user_all_forms_directory(Default_tax_year)+"/#{CA_current_year.jurisdiction.ots_form_filename}/")
  end # ots_user_all_forms_directory

  def test_jurisdiction
    assert_equal(Filing::US, US_current_year.jurisdiction)
  end # jurisdiction

  def test_open_tax_solver_distribution_directory
    assert_pathname_exists(US1040_template.filing.open_tax_solver_distribution_directory)
  end # open_tax_solver_distribution_directory

  def test_open_tax_solver_binary
    assert_match(/CA_540_#{Default_tax_year}$/, CA540_example.filing.open_tax_solver_binary)
  end # open_tax_solver_binary
	
	def test_assert_pre_conditions
		us_2016 = Filing::CA.new(tax_year: 2016)
		assert_include(us_2016.methods, :assert_pre_conditions, us_2016.inspect)
		assert_include(Filing.instance_methods, :assert_pre_conditions)
        Filing::CA.new(tax_year: 2016).assert_pre_conditions
        CA_current_year.assert_pre_conditions
        NJ_current_year.assert_pre_conditions
        Filing::NJ.new(tax_year: 2016).assert_pre_conditions
        NY_current_year.assert_pre_conditions
        Filing::NY.new(tax_year: 2016).assert_pre_conditions
        OH_current_year.assert_pre_conditions
        Filing::OH.new(tax_year: 2016).assert_pre_conditions
        PA_current_year.assert_pre_conditions
        Filing::PA.new(tax_year: 2016).assert_pre_conditions
        US_current_year.assert_pre_conditions
        Filing::US.new(tax_year: 2016).assert_pre_conditions
        VA_current_year.assert_pre_conditions
        Filing::VA.new(tax_year: 2016).assert_pre_conditions
	end # assert_pre_conditions

      def test_Filing_Examples
				assert_equal('OpenTableExplorer::Finance::Filing::CA', CA_current_year.class.name.to_s)
				assert_equal(OpenTableExplorer::Finance::Default_tax_year, CA_current_year.tax_year)
      end # Examples
end # Filing
class TaxPayerTest < TestCase
  include OpenTableExplorer::Finance
  include OpenTableExplorer::Finance::DefinitionalConstants
  extend OpenTableExplorer::Finance::DefinitionalConstants
  include OpenTableExplorer::Finance
  extend OpenTableExplorer::Finance
  include OpenTableExplorer::Finance::OtsRun::Examples
  include OpenTableExplorer::Finance::OtsTaxpayerSchedule::Examples
	module Examples # usually constant objects of the type (easy to understand (perhaps impractical) examples for testing)
  include OpenTableExplorer::Finance
  extend OpenTableExplorer::Finance
		Example_taxpayer_name = ENV['USER'].to_sym
		User = OpenTableExplorer::Finance::OtsTaxpayer.new(name: Example_taxpayer_name, open_tax_solver_all_form_directory: Filing.ots_user_all_forms_directory, state: Filing::CA)
		Example = OtsTaxpayer.new(name: :example, open_tax_solver_all_form_directory: Filing.ots_example_all_forms_directory, state: Filing::CA)
		Template = OtsTaxpayer.new(name: :template, open_tax_solver_all_form_directory: Filing.ots_example_all_forms_directory, state: Filing::CA)
	end # Examples
	include Examples
	
	def test_OtsTaxpayer_Examples
		assert_equal(Example_taxpayer_name, User.name)
		assert_equal(Filing.ots_user_all_forms_directory, User.open_tax_solver_all_form_directory)
		assert_equal(Filing::CA, User.state)
		assert_equal(Filing.ots_user_all_forms_directory, User.open_tax_solver_all_form_directory)
		assert_equal(Filing.ots_example_all_forms_directory, Example.open_tax_solver_all_form_directory)
	end # OtsTaxpayer
end # TaxPayer

class ScheduleTest < TestCase
  include OpenTableExplorer::Finance
  include OpenTableExplorer::Finance::DefinitionalConstants
  extend OpenTableExplorer::Finance::DefinitionalConstants
  include OpenTableExplorer::Finance::Schedule::DefinitionalConstants
  include OpenTableExplorer::Finance::Schedule::Examples
  include OpenTableExplorer::Finance::OtsTaxpayerSchedule::Examples
  def test_Schedule_DefinitionalConstants
    #	assert_equal('1040', US_1040.form, US_1040.inspect)
    #	assert_equal('8889', US_8889.form, US_8889.inspect)
    assert_equal(US_current_year, US_1040.filing)
    assert_equal(Filing::US, US_1040.filing.jurisdiction)
    assert_equal('1040', US_1040.filing.jurisdiction.base_form)
  end # DefinitionalConstants

	def test_initialize
		example = Schedule.new({filing: US_current_year, form: '1040', form_prefix: 'f', form_suffix: 'a'})
		assert_equal('1040', example.form, example.ruby_lines_storage)
		assert_equal('1040', example.form)
		assert_equal('f', example.form_prefix)
		assert_equal('a', example.form_suffix)
		assert_equal(US_current_year, example.filing)
	end # initialize

  def test_schedule_name
    assert_equal('f1040', US1040_example_schedule.schedule_name)
  end # schedule_name

  def test_download
    tax_form_examples = Filing::Tax_form_examples.select do |example|
      #		example[:jurisdiction] == @filing.jurisdiction.to_s && example[:form] == @filing.form.to_s
    end # each
    #	xfdf_script_filename = @filing.jurisdiction.to_s + '_' + @filing.form + '_' + @filing.tax_year.to_s
  end # download
	def test_Schedule_Examples
		example = Schedule.new(filing: US_current_year, form: '1040', form_prefix: 'f', form_suffix: 'a')
		assert_equal('1040', example.form, example.ruby_lines_storage)
		assert_equal('f', example.form_prefix)
		assert_equal('a', example.form_suffix)
		assert_equal(US_current_year, example.filing)

		example = US_1040
    refute_nil(US_current_year)
		assert_equal('1040', example.form, example.ruby_lines_storage)
		assert_equal('f', example.form_prefix)
		assert_equal('', example.form_suffix)
		assert_equal(US_current_year, example.filing)
		assert_equal(US_current_year, US_1040.filing, US_1040.ruby_lines_storage)
	end # Examples
end # Schedule

class TaxPayerScheduleTest < TestCase
  include OpenTableExplorer::Finance
  include OpenTableExplorer::Finance::DefinitionalConstants
  extend OpenTableExplorer::Finance::DefinitionalConstants
  include OpenTableExplorer::Finance::OtsRun::Examples
  include OpenTableExplorer::Finance::OtsTaxpayerSchedule::Examples
  include RubyAssertions

  def test_run_fdf_to_pdf
  end # Run_fdf_to_pdf_default

  def	test_run_pdf_to_jpeg
  end # Run_pdf_to_jpeg_default

  def test_base_path
  end # base_path

  def test_xfdf_file
#!    assert_equal('.xfdf', US1040_example_schedule.xfdf_file[-5..-1])
  end # xfdf_file

  def test_output_pdf
#!    assert(File.exist?(US1040_example_schedule.ots.open_tax_solver_form_directory), US1040_example_schedule.ots.open_tax_solver_form_directory)
#!    assert(File.exist?(US1040_example_schedule.output_pdf), US1040_example_schedule.output_pdf)
  end # output_pdf

  def test_fillout_form
#!    assert(File.exist?(US1040_example_schedule.fillout_form), US1040_example_schedule.fillout_form)
  end # fillout_form
			
			def test_fdf_to_pdf_run
			end # fdf_to_pdf_run
			
			def test_pdf_to_jpeg_run
			end # pdf_to_jpeg_run
			
end # OtsTaxpayerSchedule

class OtsRunTest < TestCase
  include OpenTableExplorer::Finance
  include OpenTableExplorer::Finance::DefinitionalConstants
  extend OpenTableExplorer::Finance::DefinitionalConstants
  include OpenTableExplorer::Finance::OtsRun::Examples
  include OpenTableExplorer::Finance::OtsTaxpayerSchedule::Examples
  include RubyAssertions

  def test_Ots_run_default
  end # Ots_run_default

  def test_Generated_xfdf_files_default
  end # generated_xfdf_files

  def test_Errors_default
    ots = US1040_example
    errors = {}
  end # Errors_default

  def test_logical_primary_key
    #	assert_equal([], US1040_user.attribute_set, US1040_user.inspect)
  end # logical_primary_key

  def test_OtsRun_virtus
    #	sysout=`#{Command}`
    #	puts "test_run_tax_solver sysout=#{sysout}"
    assert_equal('1040', US1040_template.filing.jurisdiction.base_form)
    assert_equal('1040', US1040_example.filing.jurisdiction.base_form)
    assert_equal('1040', US1040_user.filing.jurisdiction.base_form)
    assert_equal(Filing::US, US1040_template.filing.jurisdiction)
    assert_equal(Filing::US, US1040_example.filing.jurisdiction)
    assert_equal(Filing::US, US1040_user.filing.jurisdiction)
    assert_pathname_exists(US1040_example.taxpayer.open_tax_solver_all_form_directory)
    refute_nil(US1040_example.taxpayer.open_tax_solver_all_form_directory)
  end # values

	def test_open_tax_solver_run
		assert_equal(US_current_year, US1040_user.filing)
		refute_nil(US1040_user.filing, US1040_user.inspect)
#!		refute_nil(US1040_user.open_tax_solver_run)
#!		refute_nil(CA540_user.open_tax_solver_run)
		assert_equal(US_current_year, US1040_user.filing)
		refute_nil(US1040_user.filing, US1040_user.inspect)
		US1040_user.assert_pre_conditions
		refute_nil(US1040_user.open_tax_solver_run)
		US1040_user.assert_post_conditions
		refute_nil(CA540_user.open_tax_solver_run)
		refute_nil(US1040_template.open_tax_solver_run)
		refute_nil(CA540_template.open_tax_solver_run)
		refute_nil(US1040_example.open_tax_solver_run)
		refute_nil(CA540_example.open_tax_solver_run)
	end # open_tax_solver_run

	def test_schedules
	end # schedules

		def test_errors
	end # errors

  def test_open_tax_solver_form_directory
    form = '1040'
    filing = US_current_year
    ots_run = OpenTableExplorer::Finance::OtsRun.new(taxpayer: User, filing: filing)
    refute_nil(ots_run)
    refute_nil(ots_run.filing, ots_run.ruby_lines_storage)
    refute_nil(ots_run.taxpayer, ots_run.ruby_lines_storage)
    refute_nil(ots_run.taxpayer.open_tax_solver_all_form_directory)
		assert_pathname_exists(ots_run.open_tax_solver_form_directory)
    assert_pathname_exists(US1040_template.open_tax_solver_form_directory)
  end # open_tax_solver_form_directory

  def test_taxpayer_basename
    assert_pathname_exists(CA540_template.open_tax_solver_form_directory + '/' + CA540_template.taxpayer_basename_with_year + '.txt')
    assert_equal('US_1040_example', US1040_example.taxpayer_basename)
    #	assert_equal('US_1040_example1', US1040_example1.taxpayer_basename)
    assert_equal("CA_540_#{Default_tax_year}_example", CA540_example.taxpayer_basename)
    assert_equal("CA_540_#{Default_tax_year}_template", CA540_template.taxpayer_basename)
  end # taxpayer_basename

  def test_output_xfdf_glob
#!    refute_empty(Dir[US1040_example.output_xfdf_glob])
  end # output_xfdf_glob

  def test_generated_xfdf_files_regexp
  end # generated_xfdf_files_regexp

  def test_compact_message
  end # compact_message

  def test_open_tax_solver_errors
  end # open_tax_solver_errors

  def test_explain_open_tax_solver
  end # explain_open_tax_solver

  def test_commit_minor_change!
    file = 'test/data_sources/tax_form/CA_540/CA_540_2012_example_out.txt'
    current_branch_name = Branch.current_branch_name?(Repository::This_code_repository)
    diff_run = Repository::This_code_repository.git_command('diff stash -- ' + file).assert_post_conditions
    diff_run = Repository::This_code_repository.git_command("diff #{current_branch_name} -- " + file).assert_post_conditions
    assert_operator(diff_run.output.split.size, :<=, 8, diff_run.inspect)

    #        modified:   test/data_sources/tax_form/CA_540/CA_540_2012_template_out.txt
    #        modified:   test/data_sources/tax_form/US_1040/US_1040_example1_out.txt
    #        modified:   test/data_sources/tax_form/US_1040/US_1040_example_out.txt
    #        modified:   test/data_sources/tax_form/US_1040/US_1040_example_sysout.txt
    #        modified:   test/data_sources/tax_form/US_1040/US_1040_template_out.txt
  end # commit_minor_change!
				
	def test_OtsRun_assert_pre_conditions
		OtsRun.assert_pre_conditions
	end # assert_pre_conditions
				
		def test_OtsRun_assert_post_conditions
		end # assert_post_conditions

	def test_assert_pre_conditions
		us_2016 = OpenTableExplorer::Finance::Filing::US.new(tax_year: 2016)
		ca_2016 = OpenTableExplorer::Finance::Filing::CA.new(tax_year: 2016)
		OpenTableExplorer::Finance::OtsRun.new(taxpayer: User, filing: us_2016).assert_pre_conditions
		OpenTableExplorer::Finance::OtsRun.new(taxpayer: User, filing: CA.new(tax_year: 2016)).assert_pre_conditions
		OpenTableExplorer::Finance::OtsRun.new(taxpayer: Template, filing: us_2016).assert_pre_conditions
		OpenTableExplorer::Finance::OtsRun.new(taxpayer: Template, filing: CA.new(tax_year: 2016)).assert_pre_conditions
		OpenTableExplorer::Finance::OtsRun.new(taxpayer: Example, filing: us_2016).assert_pre_conditions
		OpenTableExplorer::Finance::OtsRun.new(taxpayer: Example, filing: CA.new(tax_year: 2016)).assert_pre_conditions

#!        US1040_user.assert_pre_conditions
#1        CA540_user.assert_pre_conditions
#!        US1040_template.assert_pre_conditions
#!        CA540_template.assert_pre_conditions
#!        US1040_example.assert_pre_conditions 
#!        CA540_example.assert_pre_conditions
	end # assert_pre_conditions

		def test_assert_post_conditions
		end # assert_post_conditions

  # Assertions custom instance methods
  def test_assert_open_tax_solver
  end # assert_open_tax_solver

  def test_assert_ots_to_json
  end # assert_ots_to_json

  def test_assert_json_to_fdf
  end # assert_json_to_fdf

  def test_assert_fdf_to_pdf
  end # assert_json_to_fdf
	
	def test_OtsRun_Examples
		assert_equal(US_current_year, US1040_user.filing)
    OpenTableExplorer::Finance::OtsRun::Examples.constants.each do |e|
      value = eval(e.to_s)
      next unless value.instance_of?(OpenTableExplorer::Finance::OtsRun)
      message = "value=#{value.inspect}\n"
      assert_instance_of(OpenTableExplorer::Finance::OtsRun, value, message)
      refute_empty("../OpenTaxSolver#{Default_tax_year}_*")
      refute_empty(Dir["../OpenTaxSolver#{Default_tax_year}_*"], Dir['../OpenTaxSolver*'].inspect)
      refute_nil(Dir["../OpenTaxSolver#{Default_tax_year}_*"].sort[-1])
      refute_nil(value.taxpayer.open_tax_solver_all_form_directory, 'constant name=' + e.to_s + "\n" + message)
      assert_pathname_exists(value.taxpayer.open_tax_solver_all_form_directory, 'constant name=' + e.to_s + "\n" + '')
      assert_pathname_exists(value.open_tax_solver_form_directory, 'constant name=' + e.to_s + "\n")
#!      assert_pathname_exists(value.open_tax_solver_input, 'constant name=' + e.to_s + "\n")
#!      value.assert_pre_conditions('constant name=' + e.to_s + "\n")
#!      value.assert_post_conditions('constant name=' + e.to_s + "\n")
      # if
    end # each
#!    assert_pathname_exists(US1040_user.open_tax_solver_input)
#!    assert_pathname_exists(CA540_user.open_tax_solver_input)
    us1040_example = OpenTableExplorer::Finance::OtsRun.new(open_tax_solver_run: Pwd, run_ots_to_fdf: Pwd,
                                                            taxpayer: Example, filing: US_current_year)
    #	us1040_example = OpenTableExplorer::Finance::OtsRun.new(taxpayer: :example, filing: US_current_year, tax_year: Default_tax_year, open_tax_solver_all_form_directory: OtsRun.ots_example_all_forms_directory)
  end # Examples
end # OtsRun

class OtsTaxpayerScheduleTest < TestCase
  include OpenTableExplorer::Finance
  include OpenTableExplorer::Finance::DefinitionalConstants
  extend OpenTableExplorer::Finance::DefinitionalConstants
  include OpenTableExplorer::Finance::OtsRun::Examples
  include OpenTableExplorer::Finance::OtsTaxpayerSchedule::Examples

  # def test_run_ots_to_json
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
  # end #run_ots_to_json
  # def test_run_json_to_fdf
  #
  # 2. In the main directory, run
  # ./script/fillin_values FORM_NAME INPUT.json OUTPUT_FILE
  # where form name is something like f8829 or f1040.
  # 3. Your OUTPUT_FILE should be your desired pdf filename.
  #	sysout=`#{Open_Tax_Filler_Directory}/script/fillin_values FORM_NAME {Data_source_directory}/US_1040_OTS.json {Data_source_directory}/otff_output.pdf`

  # !/bin/bash

  #: ${YEAR_DIR:=2012}
  # FORM=$1
  # DATA=$2
  # FDF=/tmp/output.fdf

  # node script/apply_values.js ${YEAR_DIR}/definition/${FORM}.json \
  #       ${YEAR_DIR}/transform/${FORM}.json ${DATA} > /tmp/output.fdf

  # pdftk ${YEAR_DIR}/PDF/${FORM}.pdf fill_form ${FDF} output $3
  #	US1040_template.run_json_to_fdf.assert_json_to_fdf
  #	US1040_example.run_json_to_fdf.assert_json_to_fdf
  #	CA540_template.run_json_to_fdf.assert_json_to_fdf
  #	CA540_example.run_json_to_fdf.assert_json_to_fdf
  #	US1040_user.run_json_to_fdf.assert_json_to_fdf
  #	CA540_user.run_json_to_fdf.assert_json_to_fdf
  # end #run_json_to_fdf
  def test_run_ots_to_json
  end # run_ots_to_json

  def test_run_json_to_fdf
  end # run_json_to_fdf

  def test_new_from_path
  end # new_from_path

  def test_OtsTaxpayerSchedule_initialize
    assert_equal('', US1040_example_schedule.form_suffix)
#!    assert_equal('1040', US1040_example_schedule.filing.jurisdiction.base_form)
    assert_equal('f', US1040_example_schedule.form_prefix, US1040_example_schedule.ruby_lines_storage)
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
    #		assert(File.exist?(filled_in_pdf_file), filled_in_pdf_file + CA540_user.schedules.inspect)
    #		ShellCommands.new('evince ' + filled_in_pdf_file).assert_pre_conditions
    #	end # each
  end # filled_in_pdf_files
end # OtsTaxpayerSchedule
