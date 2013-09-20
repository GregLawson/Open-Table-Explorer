require 'optparse'
require 'ostruct'
require 'pp'
require_relative '../app/models/work_flow.rb'
require_relative '../app/models/command_line.rb'
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
  opts.on("-b", "--[no-]best", "Best. Merge down, no conflicts. ") do |t|
    commands+=[:test] if t
  end
end.parse!
commands=[:test] if commands.empty?
pp commands
pp ARGV


case ARGV.size
when 0 then # scite testing defaults command and file
	puts "work_flow --<command> <file>"
	this_file=File.expand_path(__FILE__)
	argv=[this_file] # incestuous default test case for scite
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
		when :best then editTestGit.best
		end #case
	end #each
end #each
WorkFlow::Git_status.execute.puts
