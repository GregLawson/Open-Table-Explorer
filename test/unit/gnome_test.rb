###########################################################################
#    Copyright (C) 2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment.rb'
require_relative '../../app/models/gnome.rb'
include Gnome::Constants
class GnomeTest < TestCase
include DefaultTests
include Gnome::Constants
#assert_equal(DefaultTestCase0, TestCase) #
#assert_equal(DefaultTestCase0, self)
def test_lsof
	lsof=ShellCommands.new('lsof')
	IO.binwrite(Data_Sources_Dir+'test.lsof', lsof.output)
end #lsof
def test_ps
	ps=ShellCommands.new('ps -ef')
	IO.binwrite(Data_Sources_Dir+'test.ps', ps.output)
end #lsof
end #Gnome

