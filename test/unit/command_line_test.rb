###########################################################################
#    Copyright (C) 2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require 'pp'
require_relative '../../app/models/command_line.rb'
class CommandLineTest < TestCase
def test_create_from_path
	path=__FILE__
	file_type=	ShellCommands.new("file "+path).execute.assert_post_conditions.puts
	basename=File.basename(path)
	ShellCommands.new("man "+basename).execute.assert_post_conditions.puts
	ShellCommands.new("info "+basename).execute.assert_post_conditions.puts
	ShellCommands.new(basename+" --help").execute.assert_post_conditions.puts
	ShellCommands.new(basename+" -h").execute.assert_post_conditions.puts
	ShellCommands.new(basename+" -v").execute.assert_post_conditions.puts
end #create_from_path
def test_
end #
def test_
end #
commands = []
OptionParser.new do |opts|
  opts.banner = "Usage: work_flow.rb --<command> files"

  opts.on("-e", "--[no-]edit", "Edit related files and versions in diffuse") do |e|
    commands+=[:edit] if e
  end
  opts.on("-d", "--[no-]downgrade", "Test downgraded related files in git branches") do |d|
    commands+=[:downgrade] if d
  end
  opts.on("-u", "--[no-]upgrade", "Test upgraded related files in git branches") do |u|
    commands+=[:upgrade] if u
  end
  opts.on("-t", "--[no-]test", "Test. No commit. ") do |t|
    commands+=[:test] if t
  end
end.parse!

pp commands
pp ARGV


def test_run
end #run
end #CommandLine