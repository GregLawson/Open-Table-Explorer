###########################################################################
#    Copyright (C) 2011-2016 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'virtus'
#require 'pathname'
# need  sudo apt-get install poppler-utils
# need nodejs
# need sudo apt-get install pdftk
#require_relative '../../app/models/no_db.rb'
require_relative '../../app/models/shell_command.rb'
require_relative '../../app/models/repository.rb'
require_relative '../../app/models/parse.rb'
module OpenTableExplorer

extend AssertionsModule

module Finance
module DefinitionalConstants # constant parameters of the type (suggest all CAPS)
Downloaded_src_dir = FilePattern.repository_dir?($0) + '/../'
IRS_pdf_directory = Pathname.new('../Tax_forms').expand_path.to_s + '/'
OTS_example_directories = Pathname.new('test/data_sources/tax_form/').expand_path.to_s
#Possible_tax_years=[2011, 2012, 2013, 2014].sort
Possible_tax_years=[2014].sort
Default_tax_year = Possible_tax_years[-1]

Open_Tax_Filler_Directory = Downloaded_src_dir+'OpenTaxFormFiller'
OpenTaxSolver_directories_glob = Downloaded_src_dir + "OpenTaxSolver#{Default_tax_year}*-*"
OpenTaxSolver_directories = Dir[OpenTaxSolver_directories_glob]
#Open_tax_solver_examples_directory="#{Open_tax_solver_directory}/examples_and_templates/"
#Open_tax_solver_input="#{Open_tax_solver_data_directory}/US_1040_example.txt"
#Open_tax_solver_sysout="#{Open_tax_solver_data_directory}/US_1040_example_sysout.txt"

#OTS_template_filename="#{Open_tax_solver_data_directory}/US_1040_template.txt"
end # DefinitionalConstants
include DefinitionalConstants

class Filing
module DefinitionalConstants # constant parameters of the type (suggest all CAPS)
Tax_form_examples = [
{jurisdiction: :CA, base_form: '540', tax_year: 2014, web_URL_prefix: "https://www.ftb.ca.gov/forms/", example_path: "2014/14_540.pdf", path_interpolation: "\#{tax_year}/14_\#{base_form}.pdf"  },
{jurisdiction: :CA, base_form: '540', tax_year: 2014, web_URL_prefix: "https://www.ftb.ca.gov/forms/", example_path: "2014/14_540ca.pdf", path_interpolation: "\#{tax_year}/14_\#{base_form}\#{form_suffix}.pdf" },
{jurisdiction: :NJ, base_form: '1040', tax_year: 2014, web_URL_prefix: "http://www.state.nj.us/treasury/taxation/pdf/current/", example_path: "1040.pdf", path_interpolation: "\#{base_form}.pdf" },
{jurisdiction: :NJ, base_form: '1040', tax_year: 2014, web_URL_prefix: "http://www.state.nj.us/treasury/taxation/pdf/current/", example_path: "1040abc.pdf", path_interpolation: "\#{base_form}\#{form_suffix}.pdf" },
{jurisdiction: :NY, base_form: 'IT201', tax_year: 2014, web_URL_prefix: "http://www.tax.ny.gov/pdf/", example_path: "2014/fillin/inc/it201_2014_fill_in.pdf", path_interpolation: "\#{@tax_year}/fillin/inc/\#{base_form.downcase}_\#{@tax_year}_fill_in.pdf" },
{jurisdiction: :NY, base_form: 'IT201', tax_year: 2014, web_URL_prefix: "http://www.tax.ny.gov/pdf/", example_path: "2014/fillin/inc/it201d_2014_fill_in.pdf", path_interpolation: "\#{@tax_year}/fillin/inc/\#{base_form.downcase}d_\#{@tax_year}_fill_in.pdf" },
{jurisdiction: :OH, base_form: 'IT1040', tax_year: 2014, web_URL_prefix: "http://www.tax.ohio.gov/portals/0/forms/ohio_individual/individual/", example_path: "\#{@tax_year}/PIT_IT1040_FI.pdf", path_interpolation: "\#{@tax_year}/PIT_IT\#{base_form}_FI.pdf" },
{jurisdiction: :PA, base_form: '40', tax_year: 2014, web_URL_prefix: "http://www.revenue.pa.gov/FormsandPublications/FormsforIndividuals/Documents/Personal%20Income%20Tax/", example_path: "2014/2014_pa-\#{base_form}.pdf", path_interpolation: "\#{@tax_year}/\#{@tax_year}_pa-40.pdf" },
{jurisdiction: :US, base_form: '1040', tax_year: 2014, web_URL_prefix: "https://www.irs.gov/pub/irs-prior/", example_path: "f1040--2014.pdf", path_interpolation: "f\#{base_form}--\#{@tax_year}.pdf" },
{jurisdiction: :US, base_form: '1040', tax_year: 2014, web_URL_prefix: "https://www.irs.gov/pub/irs-prior/", example_path: "f1040sa--2014.pdf", path_interpolation: "f\#{base_form}\#{form_suffix}--\#{@tax_year}.pdf" },
{jurisdiction: :US, base_form: '1040', tax_year: 2014, web_URL_prefix: "https://www.irs.gov/pub/irs-prior/", example_path: "f1040sd--2014.pdf", path_interpolation: "f\#{base_form}\#{form_suffix}--\#{@tax_year}.pdf" },
{jurisdiction: :US, base_form: '1040_Sched_C', tax_year: 2014, web_URL_prefix: "https://www.irs.gov/pub/irs-prior/", example_path: "f1040sc--2014.pdf", path_interpolation: "f\#{base_form}\#{form_suffix}--\#{@tax_year}.pdf" },
{jurisdiction: :VA, base_form: '760', tax_year: 2014, web_URL_prefix: "http://www.tax.virginia.gov/sites/tax.virginia.gov/files/taxforms/income-tax/", example_path: "2014/\#{base_form}2014_1.pdf", path_interpolation: "\#{@tax_year}/\#{base_form}\#{@tax_year}_1.pdf" }
]
end # DefinitionalConstants
include DefinitionalConstants
include Virtus.value_object
  values do
	attribute :tax_year, Fixnum, :default => Finance::Default_tax_year
end # values
module ClassMethods
include DefinitionalConstants
def to_s
	name[-2..-1]
end # to_s
def path_prefix
	''
end # path_prefix
def form_filename
	"#{self.to_s}_#{base_form}"
end # form_filename
def jurisdiction
	self
end # jurisdiction
def open_tax_solver_distribution_directories(tax_year)
	Finance::OpenTaxSolver_directories.select do |f|
		File.directory?(f)
	end.sort
end # open_tax_solver_distribution_directories
def open_tax_solver_distribution_directory(tax_year)
	Filing.open_tax_solver_distribution_directories(tax_year).last+'/'
end # open_tax_solver_distribution_directory
def ots_example_all_forms_directory(tax_year = Finance::Default_tax_year)
	Finance::OTS_example_directories.to_s + '/' + tax_year.to_s + '/examples_and_templates/'
end # ots_example_all_forms_directory
def ots_user_all_forms_directory(tax_year = Finance::Default_tax_year)
	open_tax_solver_distribution_directory(tax_year).to_s + '/examples_and_templates/'
end # ots_user_all_forms_directory
end # ClassMethods
extend ClassMethods
def jurisdiction
	self.class
end # jurisdiction
module Constants # constant objects of the type (e.g. default_objects)
include DefinitionalConstants
end # Constants
include Constants
def open_tax_solver_distribution_directory
	Filing.open_tax_solver_distribution_directory(@tax_year)
end # open_tax_solver_distribution_directory
module Examples # usually constant objects of the type (easy to understand (perhaps impractical) examples for testing)
include DefinitionalConstants
include Constants
#CA_current_year = CA.new(tax_year: Finance::Default_tax_year)
#NJ_current_year = NJ.new(tax_year: Finance::Default_tax_year)
#NY_current_year = NY.new(tax_year: Finance::Default_tax_year)
#OH_current_year = OH.new(tax_year: Finance::Default_tax_year)
#PA_current_year = PA.new(tax_year: Finance::Default_tax_year)
#US_current_year = US.new(tax_year: Finance::Default_tax_year)
#VA_current_year = VA.new(tax_year: Finance::Default_tax_year)
end # Examples
end # Filing

class CA < Filing
extend ClassMethods
def self.web_URL_prefix
	"https://www.ftb.ca.gov/forms/"
end # web_URL_prefix
def self.base_form
	'540'
end # base_form
def self.path_interpolation
	"\#{tax_year}/\#{tax_year.mod(100)}_\#{base_form}\#{form_suffix}.pdf"
end # path_interpolation
end # CA
class NJ < Filing
extend ClassMethods
def self.web_URL_prefix
	"http://www.state.nj.us/treasury/taxation/pdf/current/"
end # web_URL_prefix
def self.base_form
	'1040'
end # base_form
def self.path_interpolation
	"\#{base_form}\#{form_suffix}.pdf"
end # path_interpolation
end # NJ
class NY < Filing
extend ClassMethods
def self.web_URL_prefix
	"http://www.tax.ny.gov/pdf/"
end # web_URL_prefix
def self.base_form
	'IT201'
end # base_form
def self.path_interpolation
	"\#{@tax_year}/fillin/inc/\#{base_form.downcase}_\#{@tax_year}_fill_in.pdf"
end # path_interpolation
end # NY
class OH < Filing
extend ClassMethods
def self.web_URL_prefix
	"http://www.tax.ohio.gov/portals/0/forms/ohio_individual/individual/"
end # web_URL_prefix
def self.base_form
	'IT1040'
end # base_form
def self.path_interpolation
	"\#{@tax_year}/PIT_IT\#{base_form}_FI.pdf"
end # path_interpolation
end # OH
class PA < Filing
extend ClassMethods
def self.web_URL_prefix
	"http://www.revenue.pa.gov/FormsandPublications/FormsforIndividuals/Documents/Personal%20Income%20Tax/"
end # web_URL_prefix
def self.base_form
	'40'
end # base_form
def self.path_interpolation
	"\#{@tax_year}/\#{@tax_year}_\#{form_prefix}40.pdf"
end # path_interpolation
end # PA
class US < Filing
extend ClassMethods
def self.web_URL_prefix
	"https://www.irs.gov/pub/irs-prior/"
end # web_URL_prefix
def self.base_form
	'1040'
end # base_form
def self.path_interpolation
	"\#{form_prefix}\#{base_form}\#{form_suffix}--\#{@tax_year}.pdf"
end # path_interpolation
end # US
class VA < Filing
extend ClassMethods
def self.web_URL_prefix
	"http://www.tax.virginia.gov/sites/tax.virginia.gov/files/taxforms/income-tax/"
end # web_URL_prefix
def self.base_form
	'760'
end # base_form
def self.path_interpolation
	"\#{@tax_year}/\#{base_form}\#{@tax_year}_1.pdf"
end # path_interpolation
end # VA
module Examples # usually constant objects of the type (easy to understand (perhaps impractical) examples for testing)
include DefinitionalConstants
include Constants
CA_current_year = CA.new(tax_year: Finance::Default_tax_year)
NJ_current_year = NJ.new(tax_year: Finance::Default_tax_year)
NY_current_year = NY.new(tax_year: Finance::Default_tax_year)
OH_current_year = OH.new(tax_year: Finance::Default_tax_year)
PA_current_year = PA.new(tax_year: Finance::Default_tax_year)
US_current_year = US.new(tax_year: Finance::Default_tax_year)
VA_current_year = VA.new(tax_year: Finance::Default_tax_year)
end # Examples
end # Filing

class OtsRun # forward reference definition completed below
end #  OtsRun

class Taxpayer
include Virtus.value_object
  values do
 	attribute :name, String
	attribute :open_tax_solver_all_form_directory, Pathname
	attribute :state, Class, :default => CA
end # values
def open_tax_solver_chdir
	(Pathname.new(@open_tax_solver_all_form_directory) + '../').cleanpath
end # open_tax_solver_chdir
module Examples # usually constant objects of the type (easy to understand (perhaps impractical) examples for testing)
Example_taxpayer_name = ENV['USER'].to_sym
User = Taxpayer.new(name: Example_taxpayer_name, open_tax_solver_all_form_directory: Filing.ots_user_all_forms_directory)
Example = Taxpayer.new(name: :example, open_tax_solver_all_form_directory: Filing.ots_example_all_forms_directory)
Template = Taxpayer.new(name: :template, open_tax_solver_all_form_directory: Filing.ots_example_all_forms_directory)
end # Examples
end # Taxpayer
class OtsRun # forward reference definition completed below
end #  OtsRun

class Schedule
include Virtus.value_object
  values do
 	attribute :filing, Filing
	attribute :form_prefix, String, :default => ''
	attribute :form_suffix, String, :default => ''
end # values
def schedule_name
	@form_prefix + @filing.base_form.to_s  + @form_suffix.to_s
end # schedule_name
def download
	command_string = 'wget ' + @filing.web_URL_prefix + eval(@filing.path_interpolation)
	FileIPO.new(command_string: command_string, chdir: Finance::IRS_pdf_directory).run
#	ShellCommands.new(xfdf_script + ' ' + @ots.open_tax_solver_output.to_s)
end # download
module Examples
end # Examples
end # Schedule
class TaxpayerSchedule # forward reference definition completed below
module DefinitionalConstants # constant parameters of the type (suggest all CAPS)
Run_fdf_to_pdf_default = lambda do |schedule, attribute|
	FileIPO.new(input_paths: [schedule.xfdf_file], command_string: "pdftk fillout_form fill_form #{schedule.xfdf_file} output #{schedule.xfdf_file}.pdf", output_paths: [schedule.xfdf_file + '.pdf']).run
#		ShellCommands.new("pdftk fillout_form fill_form #{xfdf_file} output #{xfdf_file}.pdf")
	self
end # Run_fdf_to_pdf_default
Run_pdf_to_jpeg_default = lambda do |schedule, attribute|
	output_pdf_pathname = Pathname.new(File.expand_path(schedule.output_pdf))
	cleanpath_name = output_pdf_pathname.cleanpath
	clean_directory = Pathname.new(File.expand_path(schedule.ots.open_tax_solver_form_directory)).cleanpath
	output_pdf = cleanpath_name.relative_path_from(clean_directory)
	@pdf_to_jpeg_run = FileIPO.new(input_paths: [output_pdf], command_string: "pdftoppm -jpeg  #{output_pdf} #{schedule.ots.taxpayer_basename_with_year}").run
#	@pdf_to_jpeg_run = ShellCommands.new("pdftoppm -jpeg  #{output_pdf} #{@ots.taxpayer_basename_with_year}", :chdir=>@ots.open_tax_solver_form_directory)
	@display_jpeg_run = ShellCommands.new("display  " + output_pdf) if $VERBOSE
	@display_jpeg_run.assert_post_conditions if $VERBOSE
	@pdf_to_jpeg_run
end # Run_pdf_to_jpeg_default
end # DefinitionalConstants
include DefinitionalConstants
include Virtus.value_object
  values do
 	attribute :ots, OtsRun
	attribute :form_prefix, String, :default => ''
	attribute :form_suffix, Time, :default => ''
	attribute :cached_fdf_to_pdf_run, FileIPO #, :default => TaxpayerSchedule::Run_fdf_to_pdf_default
	attribute :cached_pdf_to_jpeg_run, FileIPO #, :default => TaxpayerSchedule::Run_pdf_to_jpeg_default
end # values
def schedule_name
	@form_prefix + @ots.filing.jurisdiction.base_form.to_s  + @form_suffix.to_s
end # schedule_name
def base_path
	@ots.open_tax_solver_form_directory + '/' + @ots.taxpayer_basename + '_' + schedule_name
end # base_path
def xfdf_file
	base_path + '.xfdf'
end # xfdf_file
def matching_pdf_filename
	schedule_name + '--' + @ots.tax_year.to_s+ '.pdf'
end # 
def matching_pdf_file
	IRS_pdf_directory + matching_pdf_filename
end # 
def matching_pdf_filled_in_file
	IRS_pdf_directory + matching_pdf_filename
end # 
def output_pdf
	base_path + '.pdf'
end # output_pdf
def fillout_form
	Finance::IRS_pdf_directory + '/f' + @ots.filing.jurisdiction.base_form  + @form_suffix + '--' + @ots.tax_year.to_s + '.pdf'
end # fillout_form
# single run of ots can produce multiple Schedules
end # TaxpayerSchedule
# single run of ots can produce multiple TaxpayerSchedules

class OtsRun
include Finance::DefinitionalConstants
include OpenTableExplorer
module DefinitionalConstants # constant parameters of the type (suggest all CAPS)
Ots_run_default = lambda do |ots, attribute|
	command="#{ots.open_tax_solver_binary} #{ots.open_tax_solver_input}"
	open_tax_solver_run = FileIPO.new(input_paths: [ots.open_tax_solver_binary, ots.open_tax_solver_input], chdir: ots.open_tax_solver_chdir, command_string: command, output_paths: [ots.open_tax_solver_output]).run
	IO.binwrite(ots.open_tax_solver_sysout, open_tax_solver_run.cached_run.output)
	open_tax_solver_run
end # Ots_run_default
Run_ots_to_fdf_default = lambda do |ots, attribute|

# misses ./bin/fill_form_CA_540_2014 examples_and_templates/CA_540/CA_540_2014_greg_out.txt
# probably year in filename for state but not federal.
	xfdf_script_filename = ots.filing.jurisdiction.to_s + '_' + ots.filing.jurisdiction.base_form + '_' + ots.tax_year.to_s
	xfdf_script = '/home/greg/Desktop/src/OpenTaxSolver2014_12.01-forms/bin/fill_form_' + ots.filing.jurisdiction.to_s + '_' + ots.filing.jurisdiction.base_form + '_' + ots.tax_year.to_s
	FileIPO.new(input_paths: [xfdf_script, ots.open_tax_solver_output],
	 command_string: xfdf_script + ' ' + ots.open_tax_solver_output.to_s, chdir: Finance::IRS_pdf_directory).run
#	ShellCommands.new(xfdf_script + ' ' + ots.open_tax_solver_output.to_s)
end # run_ots_to_fdf
Generated_xfdf_files_default = lambda do |ots, attribute|
	xfdf_file_pattern = ots.generated_xfdf_files_regexp
	Dir[ots.output_xfdf_glob].map do |xfdf_file|
		xdf_capture = xfdf_file.capture?(xfdf_file_pattern)
		TaxpayerSchedule.new(ots: ots, form_prefix: xdf_capture.output?[:form_prefix],
			 form_suffix: xdf_capture.output?[:form_suffix])
	end # map
end # generated_xfdf_files
Errors_default = lambda do |ots, attribute|
	errors = {}
	errors[:open_tax_solver] = ots.open_tax_solver_errors(ots.cached_open_tax_solver_run)
	errors[:run_ots_to_fdf] = ots.cached_run_ots_to_fdf.errors
#	errors[:schedules] = ots.cached_schedules.map {|schedule| {pdf_to_jpeg_run: schedule.cached_pdf_to_jpeg_run.errors} }



end # Errors_default
end # DefinitionalConstants
include DefinitionalConstants
module DefinitionalClassMethods
include DefinitionalConstants
def open_tax_solver_distribution_directories(tax_year)
	Finance::OpenTaxSolver_directories.select do |f|
		File.directory?(f)
	end.sort
end # open_tax_solver_distribution_directories
def open_tax_solver_distribution_directory(tax_year)
	OtsRun.open_tax_solver_distribution_directories(tax_year).last+'/'
end # open_tax_solver_distribution_directory
def ots_example_all_forms_directory(tax_year = Finance::Default_tax_year)
	Finance::OTS_example_directories.to_s + '/' + tax_year.to_s + '/examples_and_templates/'
end # ots_example_all_forms_directory
def ots_user_all_forms_directory(tax_year = Finance::Default_tax_year)
	open_tax_solver_distribution_directory(tax_year).to_s + '/examples_and_templates/'
end # ots_user_all_forms_directory
def logical_primary_key
	[:taxpayer, :base_form, :jurisdiction, :tax_year, :open_tax_solver_all_form_directory]
end # logical_primary_key
end # DefinitionalClassMethods
extend DefinitionalClassMethods
include Virtus.value_object
  values do
 	attribute :taxpayer, String
# 	attribute :base_form, String
	attribute :filing, Filing
	attribute :tax_year, Fixnum, :default => Finance::Default_tax_year
	attribute :open_tax_solver_all_form_directory, Pathname
	attribute :cached_open_tax_solver_run, ShellCommands, :default => OtsRun::Ots_run_default
	attribute :cached_run_ots_to_fdf, ShellCommands, :default => OtsRun::Run_ots_to_fdf_default
	attribute :cached_schedules, Array, :default => OtsRun::Generated_xfdf_files_default
	attribute :errors, Hash, :default => OtsRun::Errors_default
end # values
def open_tax_solver_distribution_directory
	OtsRun.open_tax_solver_distribution_directory(@tax_year)
end # open_tax_solver_distribution_directory

def open_tax_solver_form_directory 
	 @open_tax_solver_all_form_directory + @filing.jurisdiction.form_filename + '/'
end # open_tax_solver_form_directory
def open_tax_solver_chdir
	(Pathname.new(@open_tax_solver_all_form_directory) + '../').cleanpath
end # open_tax_solver_chdir
def taxpayer_basename_with_year
	@filing.jurisdiction.form_filename + '_' +  @tax_year.to_s + '_' + @taxpayer
end # taxpayer_basename_with_year
def taxpayer_basename 
	if File.exists?(open_tax_solver_form_directory + '/' + taxpayer_basename_with_year+'.txt') then
		 taxpayer_basename_with_year
	else
		"#{@filing.jurisdiction.form_filename}_#{@taxpayer}"
	end #if
end # taxpayer_basename 
def open_tax_solver_binary
	"#{open_tax_solver_distribution_directory}/bin/taxsolve_#{@filing.jurisdiction.form_filename}_#{@tax_year}"
end # open_tax_solver_binary
def open_tax_solver_input
	"#{open_tax_solver_form_directory}/#{taxpayer_basename}.txt"
end # open_tax_solver_input
def open_tax_solver_output
	Pathname.new("#{open_tax_solver_form_directory}/#{taxpayer_basename}_out.txt").cleanpath
end # open_tax_solver_output
def open_tax_solver_sysout
	"#{open_tax_solver_form_directory}/#{taxpayer_basename}_sysout.txt"
end # open_tax_solver_sysout
def output_xfdf_glob 
	 "#{open_tax_solver_form_directory}/#{taxpayer_basename}*.xfdf"
end # output_xfdf_glob 
def generated_xfdf_files_regexp
	jurisdiction_pattern = /#{@filing.jurisdiction.to_s}/.capture(:jurisdiction)
	form_pattern = /#{@filing.jurisdiction.base_form}/.capture(:base_form)
	taxpayer_pattern = /#{@taxpayer}/.capture(:taxpayer)
	optional_year = (/#{@tax_year.to_s}/.capture(:tax_year) * '_').group * Regexp::Optional
	schedule_pattern = /_/* /[a-z]*/.capture(:form_prefix) * /#{@filing.jurisdiction.base_form}/ * /[a-z]*/.capture(:form_suffix) * /.xfdf/
	xfdf_file_pattern = jurisdiction_pattern * /_/ * form_pattern * /_/ * optional_year * taxpayer_pattern * schedule_pattern
end # generated_xfdf_files_regexp
def new_from_xfdf_path(ots, xfdf_file)
		xdf_capture = xfdf_file.capture?(xfdf_file_pattern)
		TaxpayerSchedule.new(ots, xdf_capture.output?[:form_prefix], xdf_capture.output?[:form_suffix])
end # new_from_path
def compact_message(string, max_length = 256)
	splitter = "\n... "
	chunk_size = (max_length-splitter.size) / 2
		if string.size > max_length then
			string[0..chunk_size-1] + "\n... " + string[-chunk_size..-1]
		else
			string # short enough already
		end # if
end # compact_message
def open_tax_solver_errors(open_tax_solver_run = @cached_open_tax_solver_run)
	errors = open_tax_solver_run.errors
#	errors[:success?] = open_tax_solver_run.success?
#	errors[:process_status] = open_tax_solver_run.process_status
#	errors[:exit_status] = open_tax_solver_run.process_status.exitstatus
	if File.exists?(open_tax_solver_sysout) then
		sysout = IO.binread(open_tax_solver_sysout)
		errors[:sysout] = compact_message(sysout,300)
		errors[:ots_errors] = sysout.split("\n").map do |line|
			regexp = /Error:/ * /[^']*/.capture(:error) * /'/ * /.+/.capture(:string_argument) * /'/
			capture = line.capture_start(regexp)
			if capture.success? then
				capture.output?
			else
				nil
			end # if
		end.compact # map
	else
		errors[:sysout] = "\n file = #{open_tax_solver_sysout} does not exist"
	end #if
	if File.exists?(open_tax_solver_output) then
		errors[:output] = compact_message(IO.binread(open_tax_solver_output),300)
	else
		errors[:output] = "\n file = #{open_tax_solver_output} does not exist"
	end #if
	if open_tax_solver_run.errors != '' then
		errors[:syserr] = open_tax_solver_run.errors
	end # if
	errors[:exception_string] = case errors[:exitstatus]
	when 0 then 
		'passed'
	when 1 then
		'OTS Error'
	when 2 then
		'unknown 2'
	else
		'unknown'
	end #case
	errors
end # open_tax_solver_errors
def explain_open_tax_solver(open_tax_solver_run = @cached_open_tax_solver_run)
	message = ''
	open_tax_solver_errors(open_tax_solver_run).each_pair do |key, value|
		if (key.to_s.size +  value.to_s.size) > 80 then
			message += key.to_s + ": \n" + value.to_s + "\n"
		else
			message += key.to_s + ": " + value.to_s + "\n"
		end # if
	end # each_pair
	message
end # explain_open_tax_solver
def commit_minor_change!(files, commit_message)
	files.each do |file|
		diff_run = Repository::This_code_repository.git_command('diff -- '+file)
		if diff_run.output.split.size==4 then
			Repository::This_code_repository.git_command('add '+file)
		end #if
		Repository::This_code_repository.git_command('commit -m '+commit_message)
	end #each
end #commit_minor_change!
module Assertions
include RubyAssertions
module ClassMethods

def assert_pre_conditions(message='')
	message += "In assert_pre_conditions, self=#{inspect}"
	refute_nil(ENV['USER'], "ENV['USER']\n" + "User nil\n" + message) # defined in Xfce & Gnome
	warn {refute_nil(ENV['USERNAME'], "ENV['USERNAME']\n" + message) } # not defined in Xfce.
	refute_nil(OpenTableExplorer::Finance::Constants::Downloaded_src_dir, OpenTableExplorer::Finance::Constants::Downloaded_src_dir + message)
	assert_pathname_exists(OpenTableExplorer::Finance::Constants::Downloaded_src_dir, message)
#	assert_pathname_exists(OpenTableExplorer::Finance::Constants::Open_Tax_Filler_Directory)
#	assert_directory_exists(OpenTableExplorer::Finance::Constants::Open_Tax_Filler_Directory)
	OpenTableExplorer::Finance::Constants::Possible_tax_years. each do |tax_year|
		default_open_tax_solver_glob = OpenTableExplorer::Finance::Constants::Downloaded_src_dir+"OpenTaxSolver#{tax_year}_*"
		default_open_tax_solver_directories = Dir[default_open_tax_solver_glob]
		refute_empty(default_open_tax_solver_directories.to_a, 'default_open_tax_solver_glob='+ default_open_tax_solver_glob)
		assert_pathname_exists(default_open_tax_solver_directories.sort[-1], default_open_tax_solver_directories.inspect)
	end # each
end #assert_pre_conditions
def assert_post_conditions(message='')
end #assert_post_conditions
end #ClassMethods
def assert_pre_conditions(message='')
	message += "In assert_pre_conditions, self=#{inspect}"
	assert_directory_exists(open_tax_solver_distribution_directory, message)
	assert_directory_exists(open_tax_solver_form_directory, message)
	assert_pathname_exists(open_tax_solver_binary, message)
end #assert_pre_conditions
def assert_post_conditions(message='')
	message+="In assert_post_conditions, self=#{inspect}"
	assert_directory_exists(open_tax_solver_distribution_directory, message)
	assert_directory_exists(open_tax_solver_form_directory, message)
	assert_data_file(open_tax_solver_output, message)
	self
end #assert_post_conditions
# Assertions custom instance methods
# possibly different runs (open_tax_solver_run) in context of OtsRun self
def assert_open_tax_solver(open_tax_solver_run = @cached_open_tax_solver_run)
	message = explain_open_tax_solver(open_tax_solver_run)
#	open_tax_solver_run.assert_post_conditions(message)
	assert(open_tax_solver_run.success?, message)
	assert_pathname_exists(open_tax_solver_output, message)
	assert_pathname_exists(open_tax_solver_sysout, message)
end #assert_open_tax_solver
#def assert_ots_to_json
#	@ots_to_json_run.assert_post_conditions
#	assert_empty(Dir[' test/data_sources/tax_form/examples_and_templates/US_1040/US_1040_*_OTS.json~passed'])
#end #assert_ots_to_json
#def assert_json_to_fdf
#	@json_to_fdf_run.assert_post_conditions
#end #assert_json_to_fdf
def assert_fdf_to_pdf
	@script_run.assert_post_conditions
	assert(File.exist?(@xfdf_script), @xfdf_script)
end #assert_json_to_fdf
def assert_pdf_to_jpeg
	@pdf_to_jpeg_run.assert_post_conditions
end #assert_json_to_fdf
end #Assertions
include Assertions
extend Assertions::ClassMethods
OpenTableExplorer::Finance::OtsRun #.assert_pre_conditions # verify Constants can be created
module Examples
include DefinitionalConstants
include Finance
include FileIPO::Examples
#include Filing
include Filing::Examples
Example_Taxpayer=ENV['USER'].to_sym
include Taxpayer::Examples
#refute_empty(OpenTaxSolver_directories, OpenTaxSolver_directories_glob)
#refute_empty(OtsRun.open_tax_solver_distribution_directory)
US1040_user = OpenTableExplorer::Finance::OtsRun.new(taxpayer: Example_Taxpayer, filing: US, tax_year: Default_tax_year, open_tax_solver_all_form_directory: Filing.ots_user_all_forms_directory)
CA540_user=OpenTableExplorer::Finance::OtsRun.new(taxpayer: Example_Taxpayer, filing: CA, tax_year: Default_tax_year, open_tax_solver_all_form_directory: Filing.ots_user_all_forms_directory)
US1040_template=OpenTableExplorer::Finance::OtsRun.new(taxpayer: :template, filing: US, tax_year: Default_tax_year, open_tax_solver_all_form_directory: Filing.ots_example_all_forms_directory)
CA540_template=OpenTableExplorer::Finance::OtsRun.new(taxpayer: :template, filing: CA, tax_year: Default_tax_year, open_tax_solver_all_form_directory: Filing.ots_example_all_forms_directory)
US1040_example=OpenTableExplorer::Finance::OtsRun.new(taxpayer: :example, filing: US, tax_year: Default_tax_year, open_tax_solver_all_form_directory: Filing.ots_example_all_forms_directory)
#US1040_example1=OpenTableExplorer::Finance::OtsRun.new(taxpayer: :example1, filing: US, tax_year: Default_tax_year, open_tax_solver_all_form_directory: Filing.ots_example_all_forms_directory)
CA540_example=OpenTableExplorer::Finance::OtsRun.new(taxpayer: :example, filing: CA, tax_year: Default_tax_year, open_tax_solver_all_form_directory: Filing.ots_example_all_forms_directory)
Simplified_example = OpenTableExplorer::Finance::OtsRun.new(cached_open_tax_solver_run: Pwd, cached_run_ots_to_fdf: Pwd,
																				taxpayer: :example, filing: US, tax_year: Default_tax_year, open_tax_solver_all_form_directory: Filing.ots_example_all_forms_directory)

Expect_to_pass=[US1040_user, CA540_user, US1040_example, CA540_example]
Expect_to_fail=[US1040_template, CA540_template]
#US1040_example.assert_pre_conditions
end #Examples
OpenTableExplorer::Finance::OtsRun.assert_post_conditions # verify Constants were created correctly
end #OtsRun

# a ots run can produce multiple schedule outputs
# mapping is in: 
#
class TaxpayerSchedule
module ClassMethods
def run_ots_to_json
	@open_tax_form_filler_ots_js="#{Open_Tax_Filler_Directory}/script/json_ots.js"
	@ots_json="#{open_tax_solver_form_directory}/#{taxpayer_basename}_OTS.json"
	command="nodejs #{@open_tax_form_filler_ots_js} #{open_tax_solver_output} > #{@ots_json}"
	@ots_to_json_run=ShellCommands.new(command)
#	assert_pathname_exists(@ots_json)
	self
end #run_ots_to_json
def run_json_to_fdf
	form='Federal/f1040'
	form_filename=form.sub('/','_')
	if @jurisdiction == US then
		@otff_form='Federal/f'+@jurisdiction.base_form.to_s
	else
		@otff_form=@jurisdiction.to_s+'/f'+@jurisdiction.base_form.to_s
	end #if
	@fdf='/tmp/output.fdf'
	output_pdf="#{open_tax_solver_form_directory}/#{taxpayer_basename_with_year}_otff.pdf"
#	assert_pathname_exists(@ots_json, @ots_json.inspect)
	pdf_input="#{Open_Tax_Filler_Directory}/"
#	assert_pathname_exists(@ots_json)
	command="nodejs #{Open_Tax_Filler_Directory}/script/apply_values.js #{Open_Tax_Filler_Directory}/#{@tax_year}/definition/#{@otff_form}.json #{Open_Tax_Filler_Directory}/#{@tax_year}/transform/#{@otff_form}.json #{@ots_json} > #{@fdf}"
	@json_to_fdf_run=ShellCommands.new(command)
	self
end #run_json_to_fdf
end #ClassMethods
extend ClassMethods
attr_reader :ots, :form_prefix, :form_suffix
module Examples
end # Examples
end # TaxpayerSchedule
end #Finance
end #OpenTableExplorer
