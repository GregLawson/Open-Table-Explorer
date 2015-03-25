###########################################################################
#    Copyright (C) 2014 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
#require 'virtus'
#require_relative '../../app/models/no_db.rb'
require_relative '../../app/models/shell_command.rb'
class Dependancy
module ClassMethods
end # ClassMethods
extend ClassMethods
module Constants
end # Constants
include Constants
# attr_reader
def initialize(name)
	@name = name
end # initialize
def apt
	install_execution=ShellCommands.new('sudo apt-get install ' + @name).assert_post_conditions
end # apt
def gem
	require @name
rescue LoadError
	install_execution=ShellCommands.new('sudo gem install ' + @name).assert_post_conditions
end # gem
require_relative '../../test/assertions.rb'
module Assertions
module ClassMethods
def assert_pre_conditions(message='')
	message+="In assert_pre_conditions, self=#{inspect}"
end #assert_pre_conditions
def assert_post_conditions(message='')
	message+="In assert_post_conditions, self=#{inspect}"
end #assert_post_conditions
end #ClassMethods
def assert_pre_conditions(message='')
end #assert_pre_conditions
def assert_post_conditions(message='')
end #assert_post_conditions
end # Assertions
include Assertions
extend Assertions::ClassMethods
#self.assert_pre_conditions
module Examples
include Constants
end # Examples
end # Dependancy
