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
require_relative '../../app/models/generic_file.rb'
require_relative '../../app/models/shell_command.rb'
module OpenTableExplorer
include Test::Unit::Assertions
extend Test::Unit::Assertions
module Finance
module Constants
Data_source_directory='test/data_sources/taxes'
Default_tax_year=2012
Open_Tax_Filler_Directory='../OpenTaxFormFiller'
Open_tax_solver_directory=Dir["../OpenTaxSolver2012_*"][0]
Open_tax_solver_data_directory="#{Open_tax_solver_directory}/examples_and_templates/US_1040"
Open_tax_solver_input="#{Open_tax_solver_data_directory}/US_1040_example.txt"
Open_tax_solver_sysout="#{Open_tax_solver_data_directory}/US_1040_example_sysout.txt"

Open_tax_solver_binary="#{Open_tax_solver_directory}/bin/taxsolve_US_1040_2012"
Command="#{Open_tax_solver_binary} #{Open_tax_solver_input} >#{Open_tax_solver_sysout}"
OTS_template_filename="#{Open_tax_solver_data_directory}/US_1040_template.txt"
end #Constants
class TaxForms
include Constants
include OpenTableExplorer
module ClassMethods
end #ClassMethods
extend ClassMethods
attr_reader :form, :jurisdiction, :tax_year, :form_filename, :open_tax_solver_directory, :open_tax_solver_data_directory, :ots_template_filename, :output_pdf
def initialize(form, jurisdiction='US', tax_year=Finance::Constants::Default_tax_year)
	@form=form
	@jurisdiction=jurisdiction # :US, or :CA
	@tax_year=tax_year
	@open_tax_solver_directory=Dir["../OpenTaxSolver#{@tax_year}_*"][0]
	@form_filename="#{@jurisdiction.to_s}_#{@form}"
	@open_tax_solver_data_directory="#{@open_tax_solver_directory}/examples_and_templates/#{@form_filename}"
	@open_tax_solver_output="#{open_tax_solver_data_directory}/#{@form_filename}_Lawson.txt"
	@ots_template_filename="#{Open_tax_solver_data_directory}/#{@jurisdiction.to_s}_#{@form}_template.txt"
	@output_pdf="#{Data_source_directory}/#{@form_filename}_otff.pdf"
	
end #initialize
def run_open_tax_solver
	open_tax_solver_input="#{open_tax_solver_data_directory}/US_1040_Lawson.txt"
	open_tax_solver_sysout="#{open_tax_solver_data_directory}/US_1040_Lawson_sysout.txt"
	command="#{Open_tax_solver_binary} #{open_tax_solver_input} >#{open_tax_solver_sysout}"
	ShellCommands.new(command).assert_post_conditions
end #run_open_tax_solver
def run_open_tax_solver_to_filler
	command="nodejs #{@open_Tax_Filler_Directory}/script/json_ots.js #{@open_tax_solver_sysout} > #{Data_source_directory}/US_1040_OTS.json"
	ShellCommands.new(command).assert_post_conditions
end #run_open_tax_solver_to_filler
def run_pdf_to_jpeg
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
def assert_pre_conditions
end #assert_pre_conditions
def assert_post_conditions
	assert(File.exists?(@open_tax_solver_directory), caller_lines)
	assert(File.exists?(@open_tax_solver_data_directory), caller_lines)
	assert(File.exists?(@open_tax_solver_output), caller_lines)
	assert(File.exists?(@ots_template_filename), caller_lines)
end #assert_post_conditions
end #Assertions
include Assertions
extend Assertions::ClassMethods
#self.assert_pre_conditions
module Examples
end #Examples
end #TaxForms
end #Finance
end #OpenTableExplorer
