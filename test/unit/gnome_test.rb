require_relative 'test_environment.rb'
require_relative '../../app/models/shell_command.rb'
class Gnome
module Constants
Data_Sources_Dir=TE.data_sources_directory?+'gnome_hangs/'
end #Constants
include Constants
end #Gnome
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
end #GnomeTest

