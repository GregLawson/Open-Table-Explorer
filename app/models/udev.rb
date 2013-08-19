require_relative '../../app/models/shell_command.rb'
class Udev
attr_reader :related_files, :edit_files
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
end #Assertions
include Assertions
#TestWorkFlow.assert_pre_conditions
module Constants
Lib_udev=ShellCommands.new("ls /lib/udev/rules.d/*", :delay_execution)
Etc_udev=ShellCommands.new("ls /etc/udev/rules.d/*", :delay_execution)
end #Constants
include Constants
module Examples
include Constants
end #Examples
include Examples
end #WorkFlow
