###########################################################################
#    Copyright (C) 2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
# need  sudo apt-get install poppler-utils
# need nodejs
# need sudo apt-get install pdftk
require_relative '../../app/models/no_db.rb'
require_relative '../../app/models/shell_command.rb'
module OpenTableExplorer
include Test::Unit::Assertions
extend Test::Unit::Assertions
module Finance
module Constants
#Data_source_directory='test/data_sources/taxes'
Default_tax_year=2012
Open_Tax_Filler_Directory='../OpenTaxFormFiller-master'
#Open_tax_solver_data_directory="#{Open_tax_solver_directory}/examples_and_templates/US_1040"
#Open_tax_solver_input="#{Open_tax_solver_data_directory}/US_1040_example.txt"
#Open_tax_solver_sysout="#{Open_tax_solver_data_directory}/US_1040_example_sysout.txt"

#OTS_template_filename="#{Open_tax_solver_data_directory}/US_1040_template.txt"
end #Constants
class TaxForm
include Constants
include OpenTableExplorer
module ClassMethods
end #ClassMethods
extend ClassMethods
attr_reader :form, :jurisdiction, :tax_year, :form_filename, :taxpayer_basename, 
:taxpayer_basename_with_year, :open_tax_solver_binary, :open_tax_solver_directory, 
:open_tax_solver_to_filler_run, 
:open_tax_solver_input, :open_tax_solver_data_directory, :open_tax_solver_output,
:ots_template_filename, :ots_json, :ots_to_json_run,
:output_pdf
def initialize(taxpayer, form, jurisdiction=:US, tax_year=Finance::Constants::Default_tax_year)
	@taxpayer=taxpayer.to_s
	@form=form
	@jurisdiction=jurisdiction # :US, or :CA
	@tax_year=tax_year
	@open_tax_solver_directory=Dir["../OpenTaxSolver#{@tax_year}_*"].sort[-1]
	@form_filename="#{@jurisdiction.to_s}_#{@form}"
	@open_tax_solver_data_directory="#{@open_tax_solver_directory}/examples_and_templates/#{@form_filename}/"
	@taxpayer_basename="#{@form_filename}_#{@taxpayer}"
	@taxpayer_basename_with_year=@form_filename+'_'+@tax_year.to_s+'_'+@taxpayer
	if File.exists?(@open_tax_solver_data_directory+'/'+@taxpayer_basename_with_year+'.txt') then
		@taxpayer_basename=@taxpayer_basename_with_year
	end #if
	@open_tax_solver_binary="#{@open_tax_solver_directory}/bin/taxsolve_#{@form_filename}_#{@tax_year}"
	if !File.exists?(@open_tax_solver_binary) then
		@open_tax_solver_binary="#{Dir["../OpenTaxSolver#{@tax_year-1}_*"].sort[-1]}/bin/taxsolve_#{@form_filename}_#{@tax_year-1}"
		warn("@open_tax_solver_binary=#{@open_tax_solver_binary}")
	end #if
	@open_tax_solver_input="#{open_tax_solver_data_directory}/#{@taxpayer_basename}.txt"
	@open_tax_solver_output="#{open_tax_solver_data_directory}/#{@taxpayer_basename}_out.txt"
	@open_tax_solver_sysout="#{open_tax_solver_data_directory}/#{@taxpayer_basename}_sysout.txt"
	@output_pdf="#{@open_tax_solver_data_directory}/taxes/#{@taxpayer_basename}_otff.pdf"
	
end #initialize
def build
	run_open_tax_solver
	run_ots_to_json
	run_json_to_fdf
	run_fdf_to_pdf
	run_pdf_to_jpeg
	self
end #build
def run_open_tax_solver

	command="#{@open_tax_solver_binary} #{@open_tax_solver_input} >#{@open_tax_solver_sysout}"
	@open_tax_solver_run=ShellCommands.new(command)
	self
end #run_open_tax_solver
def run_ots_to_json
	@open_tax_form_filler_ots_js="#{Open_Tax_Filler_Directory}/script/json_ots.js"
	@ots_json="#{@open_tax_solver_data_directory}/#{@taxpayer_basename}_OTS.json"
	command="nodejs #{@open_tax_form_filler_ots_js} #{@open_tax_solver_output} > #{@ots_json}"
	@ots_to_json_run=ShellCommands.new(command)
	assert_pathname_exists(@ots_json)
	self
end #run_ots_to_json
def run_json_to_fdf
	form='Federal/f1040'
	form_filename=form.sub('/','_')
	if @jurisdiction==:US then
		@otff_form='Federal/f'+@form.to_s
	else
		@otff_form=@jurisdiction.to_s+'/f'+@form.to_s
	end #if
	@fdf='/tmp/output.fdf'
	output_pdf="#{@open_tax_solver_data_directory}/#{@taxpayer_basename_with_year}_otff.pdf"
	assert_pathname_exists(@ots_json)
	pdf_input="#{Open_Tax_Filler_Directory}/"
	assert_pathname_exists(@ots_json)
	command="nodejs #{Open_Tax_Filler_Directory}/script/apply_values.js #{Open_Tax_Filler_Directory}/#{@tax_year}/definition/#{@otff_form}.json #{Open_Tax_Filler_Directory}/#{@tax_year}/transform/#{@otff_form}.json #{@ots_json} > #{@fdf}"
	@json_to_fdf_run=ShellCommands.new(command)
	self
end #run_json_to_fdf
def run_fdf_to_pdf
#	assert_pathname_exists(@open_tax_solver_data_directory, @open_tax_solver_data_directory+' does not exist')
	@fdf_to_pdf_run=ShellCommands.new("pdftk #{Open_Tax_Filler_Directory}/#{@tax_year}/PDF/#{@otff_form}.pdf fill_form #{@fdf} output #{output_pdf}")
#	assert_pathname_exists(@open_tax_solver_data_directory+'Federal_f1040_otff.pdf', Dir[@open_tax_solver_data_directory+'*'].join(';'))
	@evince_run=ShellCommands.new("evince @open_tax_solver_data_directory+Federal_f1040_otff.pdf") if $VERBOSE
	@evince_run.assert_post_conditions if $VERBOSE
	self
end #run_fdf_to_pdf
def run_pdf_to_jpeg
	
	@pdf_to_jpeg_run=ShellCommands.new("pdftoppm -jpeg  #{output_pdf} #{form_filename}")
	@display_jpeg_run=ShellCommands.new("display  Federal_f1040-1.jpg") if $VERBOSE
	@display_jpeg_run.assert_post_conditions if $VERBOSE
	self
end #run_pdf_to_jpeg
module Assertions
include Test::Unit::Assertions
module ClassMethods
include Test::Unit::Assertions
def assert_pre_conditions
end #assert_pre_conditions
def assert_post_conditions
end #assert_post_conditions
end #ClassMethods
def assert_open_tax_solver
	assert_pathname_exists(@open_tax_solver_input)
#	@open_tax_solver_run.assert_post_conditions
	peculiar_status=@open_tax_solver_run.process_status.exitstatus==1
	message=IO.binread(@open_tax_solver_sysout)+@open_tax_solver_run.errors
	@open_tax_solver_run.puts
	puts "peculiar_status=#{peculiar_status}"
	puts "message='#{message}'"
	if peculiar_status then
		warn(message)
		warn('!@open_tax_solver_run.success?='+(!@open_tax_solver_run.success?).to_s)
	else
		@open_tax_solver_run.assert_post_conditions('else peculiar_status')
	end #if
	assert_pathname_exists(@open_tax_solver_output)
	assert_pathname_exists(@open_tax_solver_sysout)
end #assert_open_tax_solver
def assert_json_to_fdf
	@json_to_fdf_run.assert_post_conditions
end #assert_json_to_fdf
def assert_fdf_to_pdf
	@fdf_to_pdf_run.assert_post_conditions
end #assert_json_to_fdf
def assert_pdf_to_jpeg
	@pdf_to_jpeg_run.assert_post_conditions
end #assert_json_to_fdf
def assert_build
#	@open_tax_solver_run.assert_open_tax_solver
#	@ots_to_json_run.assert_ots_to_json
#	@json_to_fdf_run.assert_json_to_fdf
#	@fdf_to_pdf_run.assert_fdf_to_pdf
#	@pdf_to_jpeg_run.assert_pdf_to_jpeg
	if !@open_tax_solver_run.success? then
		assert_open_tax_solver
	elsif !@ots_to_json_run.success? then
		assert_ots_to_json
	elsif !@json_to_fdf_run.success? then
		assert_json_to_fdf
	elsif !@fdf_to_pdf_run.success? then
				@fdf_to_pdf_run.puts
	else
		assert_pdf_to_jpeg
	end #if
	self
end #build
def assert_pre_conditions
	assert_pathname_exists(@open_tax_solver_input)
end #assert_pre_conditions
def assert_post_conditions
	assert_pathname_exists(@open_tax_solver_directory, caller_lines)
	assert_pathname_exists(@open_tax_solver_data_directory, caller_lines)
	assert_pathname_exists(@open_tax_solver_output, caller_lines)
end #assert_post_conditions
end #Assertions
include Assertions
extend Assertions::ClassMethods
#self.assert_pre_conditions
module Examples
Example_Taxpayer=ENV['USERNAME'].to_sym
US1040_user=OpenTableExplorer::Finance::TaxForm.new(Example_Taxpayer, '1040', :US)
CA540_user=OpenTableExplorer::Finance::TaxForm.new(Example_Taxpayer, '540', :CA)
US1040_template=OpenTableExplorer::Finance::TaxForm.new(:template, '1040', :US)
CA540_template=OpenTableExplorer::Finance::TaxForm.new(:template, '540', :CA)
US1040_example=OpenTableExplorer::Finance::TaxForm.new(:example, '1040', :US)
US1040_example1=OpenTableExplorer::Finance::TaxForm.new(:example1, '1040', :US)
CA540_example=OpenTableExplorer::Finance::TaxForm.new(:"2012_example", '540', :CA)
end #Examples
end #TaxForm
end #Finance
end #OpenTableExplorer
