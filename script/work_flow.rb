require 'optparse'
require 'ostruct'
require 'pp'
require_relative '../app/models/work_flow.rb'
class CommandLine
def initialize(name, description=name)
	@name=name
	@description=description
end #initialize
def add_option(option)
	@options = (@options.nil? ? [] : @options)+[option]
end #add_option
end #CommandLine
class CommandLineOption
def initialize(name, description=name, short_option=name[0], long_option=name)
	@name=name
	@description=description
	@short_option=short_option
	@long_option=long_option
end #initialize
end #CommandLineOption
commands = []
OptionParser.new do |opts|
  opts.banner = "Usage: work_flow.rb --<command> files"

  opts.on("-e", "--[no-]edit", "Edit related files and versions in diffuse") do |v|
    commands+=[:edit] if v
  end
  opts.on("-d", "--[no-]downgrade", "Test downgraded related files in git branches") do |d|
    commands+=[:downgrade] if d
  end
  opts.on("-u", "--[no-]upgrade", "Test upgraded related files in git branches") do |u|
    commands+=[:upgrade] if u
  end
  opts.on("-t", "--[no-]test", "Test. No commit. ") do |u|
    commands+=[:test] if u
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
	editTestGit=WorkFlow.new(f)
	commands.each do |c|
		case c.to_sym
		when :execute then editTestGit.execute
		when :edit then editTestGit.edit
		when :test then editTestGit.test
		when :upgrade then editTestGit.upgrade
		when :downgrade then editTestGit.downgrade
		when :merge_down then editTestGit.merge_down
		end #case
	end #each
end #each
WorkFlow::Git_status.execute.puts