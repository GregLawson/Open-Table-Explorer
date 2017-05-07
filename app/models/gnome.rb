###########################################################################
#    Copyright (C) 2013-2016 by Greg Lawson
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'virtus'
require_relative '../../app/models/shell_command.rb'
class Gnome
module DefinitionalConstants # constant parameters of the type (suggest all CAPS)
Data_Sources_Dir= Unit:Executing.data_sources_directory?+'/'+Time.now.strftime("%Y-%m-%d %H:%M:%S.%L")+'/'
end # DefinitionalConstants
include DefinitionalConstants
  include Virtus.value_object
  values do
# 	attribute :branch, Symbol
#	attribute :age, Fixnum, :default => 789
#	attribute :timestamp, Time, :default => Time.now
	end # values
module ClassMethods
include DefinitionalConstants
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
def reboots
	ShellCommands.new('sudo zgrep  "Linux version" /var/log/kern*')
end # reboots
module Constants # constant objects of the type (e.g. default_objects)
end # Constants
include Constants
#require_relative '../../app/models/assertions.rb'
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
extend Assertions::ClassMethods
#self.assert_pre_conditions
module Examples
include DefinitionalConstants
include Constants
end #Examples
#include Examples
end #Gnome

