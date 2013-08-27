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
include CommandLineScript::Examples
def test_path_of_command
	assert_match('/usr/bin/ruby', CommandLine.path_of_command('ruby'))
end #path_of_command
def test_initialize
	path=File.expand_path(__FILE__)
	file_type=	ShellCommands.new("file -b "+path).execute.puts
	mime_type=	ShellCommands.new("file -b --mime "+path).execute.puts
	@dpkg="grep "#{@path}$"  /var/lib/*/info/*.list"
	if mime_type=='application/octet' then
		basename=File.basename(path)
		version=ShellCommands.new(basename+" --version").execute.output
		v=ShellCommands.new(basename+" -v").execute.output
		man=ShellCommands.new("man "+basename).execute.output
		info=ShellCommands.new("info "+basename).execute.assert_post_conditions.puts
		help=ShellCommands.new(basename+" --help").execute.assert_post_conditions.puts
		h=ShellCommands.new(basename+" -h").execute.assert_post_conditions.puts
		whereis=ShellCommands.new("whereis "+command).execute.output
	end #if
end #initialize
def test_add_option
  SELF.add_option("edit", "Edit related files and versions in diffuse")
  SELF.add_option("downgrade", "Test downgraded related files in git branches")
  SELF.add_option("upgrade", "Test upgraded related files in git branches")
  SELF.add_option("test", "Test. No commit. ")
end #add_option
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


end #CommandLine