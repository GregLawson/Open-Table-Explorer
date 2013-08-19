###########################################################################
#    Copyright (C) 2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../../app/models/shell_command.rb'
class Udev
module ClassMethods
end #ClassMethods
extend ClassMethods
require_relative '../../test/assertions/default_assertions.rb'
include DefaultAssertions
extend DefaultAssertions::ClassMethods
module Assertions
module ClassMethods
def assert_post_conditions
end #assert_post_conditions
end #ClassMethods
def assert_pre_conditions
end #assert_pre_conditions
def assert_post_conditions
end #assert_post_conditions
end #Assertions
include Assertions
#TestWorkFlow.assert_pre_conditions
module Constants
Lib_udev=ShellCommands.new("ls -1 /lib/udev/rules.d/*", :delay_execution)
Etc_udev=ShellCommands.new("ls -l /etc/udev/rules.d/*", :delay_execution)
end #Constants
include Constants
module Examples
include Constants
end #Examples
include Examples
end #Udev
