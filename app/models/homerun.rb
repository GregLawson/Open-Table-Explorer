###########################################################################
#    Copyright (C) 2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'regexp.rb'
require_relative '../../app/models/shell_command.rb'
class HomeRun
module ClassMethods
end #ClassMethods
extend ClassMethods
#include DefaultAssertions
#extend DefaultAssertions::ClassMethods
def initialize(id='10311E80')
	@id=id
end #initialize
def scan
	scan=ShellCommands.new("hdhomerun_config #{@id} scan").execute
end #scan
require 'test/unit'
module Assertions
include Test::Unit::Assertions
module ClassMethods
include Test::Unit::Assertions
def assert_post_conditions
end #assert_post_conditions
end #ClassMethods
def assert_pre_conditions
end #assert_pre_conditions
def assert_post_conditions
	assert_include(self.instance_variables, :@id, "self=#{self.inspect}")
	assert_not_nil(@id)
end #assert_post_conditions
end #Assertions
include Assertions
#TestWorkFlow.assert_pre_conditions
module Constants
Discover=ShellCommands.new('hdhomerun_config discover', :delay_execution)
Discover_example="hdhomerun device 10311E80 found at 172.31.42.101\n"
Id_pattern=/([[hex]]{8})/
Ip_pattern=/(\d{1,3}\.{3}\d{1,3})/
Discover_parse=/hdhomerun device #{Id_pattern} found at #{Ip_pattern}/
Discover_error=/^no devices found\n/
Scan_error=/^unable to connect to device\n/
Scan_error_pass=/^$/
end #Constants
include Constants
module Examples
include Constants
Default_hdhr=HomeRun.new
end #Examples
include Examples
end #HomeRun
