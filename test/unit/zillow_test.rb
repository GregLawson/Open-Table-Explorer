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
class ZillowTest < TestCase
include DefaultTests
include TE.model_class?::Examples
def test_Examples
	command_string = 'wget --no-verbose -O- ' + All_units_url
	all_units = ShellCommands.new(command_string).output
end # Examples
end # Zillow
