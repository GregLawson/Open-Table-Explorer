###########################################################################
#    Copyright (C) 2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../../app/models/shell_command.rb'
class Gnome
module Constants
Data_Sources_Dir=TE.data_sources_directory?+'/'+Time.now.strftime("%Y-%m-%d %H:%M:%S.%L")+'/'
end #Constants
include Constants
module ClassMethods
end #ClassMethods
extend ClassMethods
#include DefaultAssertions
#extend DefaultAssertions::ClassMethods
def lsof
	lsof=ShellCommands.new('lsof')
	IO.binwrite(Data_Sources_Dir+'test.lsof', lsof.output)
end #lsof
def ps
	ps=ShellCommands.new('ps -ef')
	IO.binwrite(Data_Sources_Dir+'test.ps', ps.output)
end #lsof
module Assertions
include Minitest::Assertions
module ClassMethods
include Minitest::Assertions
def assert_post_conditions
end #assert_post_conditions
end #ClassMethods
def assert_pre_conditions
end #assert_pre_conditions
def assert_post_conditions
end #assert_post_conditions
end #Assertions
include Assertions
extend Assertions::ClassMethods
#self.assert_pre_conditions
module Examples
include Constants
end #Examples
#include Examples
end #Gnome

