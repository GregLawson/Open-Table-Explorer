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
	path=	ShellCommands("file "+path).execute.assert_post_conditions.puts
	basename=File.basename(path)
	ShellCommands("man "+basename).execute.assert_post_conditions.puts
	ShellCommands("info "+basename).execute.assert_post_conditions.puts
	ShellCommands(basename+" --help").execute.assert_post_conditions.puts
	ShellCommands(basename+" -h").execute.assert_post_conditions.puts
	ShellCommands(basename+" -v").execute.assert_post_conditions.puts
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


case ARGV.size
when 0 then # scite testing defaults command and file
	puts "work_flow --<command> <file>"
	this_file=File.expand_path(__FILE__)
	argv=[this_file] # incestuous default test case for scite
	commands=[:test]
else
	argv=ARGV
end #case
argv.each do |f|
	command_line=CommandLine.new(f)
	commands.each do |c|
		case c.to_sym
		when :execute then command_line.execute
		when :edit then command_line.edit
		when :test then command_line.test
		when :upgrade then command_line.upgrade
		when :downgrade then command_line.downgrade
		when :merge_down then command_line.merge_down
		end #case
	end #each
end #each
WorkFlow::Git_status.execute.puts
end #CommandLine