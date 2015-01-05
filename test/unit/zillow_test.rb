###########################################################################
#    Copyright (C) 2014 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative '../../app/models/shell_command.rb'
require_relative '../../app/models/zillow.rb'
require_relative '../../app/models/parse.rb'
class ZillowTest < TestCase
include DefaultTests
include TE.model_class?::Examples
def test_Examples
#	command_string = 'wget --no-verbose -O- ' + All_units_url
	variant_options = ''
	command_string = 'wget ' + Basic_options + ' ' + variant_options + All_units_url
	all_units = ShellCommands.new(command_string, :chdir => Tempoary_directory).output
	all_units_path = '/tmp/zillow/wget/www.zillow.com/b/354-Chestnut-Ave-Long-Beach-CA-90802/33.77148,-118.195976_ll/index.html'
	assert_pathname_exists(all_units_path)
	all_units_html = IO.read(all_units_path)
#	apartment_pattern = /APT-[0-9]{2}/.capture(:apartment)
	apartment_pattern = /[-A-Z0-9]{2,10}/.capture(:apartment)
	search_literal = Regexp.new(Street_address + '-') * apartment_pattern * Regexp.new('-' + City + '-' + Zip)
	unit_pattern = /.{125}/.capture(:before) * Regexp.new(search_literal) * /.{125}/.capture(:after)
	all_units = Parse.parse_into_array(all_units_html, unit_pattern)
	all_units.sort{|x,y| x[:apartment] <=> y[:apartment]}.each {|l| puts l[:apartment], l[:before], l[:after]}
	table_row = /<tr/ * /.*/.capture(:row) * /<'tr>/
	rows = Parse.parse_into_array(all_units_html, table_row)
	variant_options = ' -l 1'
end # Examples
end # Zillow
