###########################################################################
#    Copyright (C) 2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
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
  opts.on("-m", "--[no-]emacs", "Emacs unit edit. ") do |t|
    commands+=[:emacs] if t
  end
  opts.on("-x", "--[no-]execute", "Unit test and edit. ") do |t|
    commands+=[:execute] if t
  end
  opts.on("-p", "--[no-]passed", "Stage file to passed. ") do |t|
    commands+=[:passed] if t
  end
  opts.on("-g", "--[no-]testing", "Stage file to testing. ") do |t|
    commands+=[:testing] if t
  end
  opts.on("-i", "--[no-]edited", "Stage file to edited. ") do |t|
    commands+=[:edited] if t
  end
  opts.on("-v", "--[no-]deserve", "Stage file to edited. ") do |t|
    commands+=[:deserve] if t
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
		when :execute then editTestGit.execute(f)
		when :edit then editTestGit.edit
		when :test then editTestGit.test(f)
		when :upgrade then editTestGit.upgrade(f)
		when :downgrade then editTestGit.downgrade(f)
		when :best then editTestGit.best(f)
		when :emacs then editTestGit.emacs(f)
		when :passed then editTestGit.repository.stage_files(:passed, [f])
		when :testing then editTestGit.repository.stage_files(:testing, [f])
		when :edited then editTestGit.repository.stage_files(:edited, [f])
		when :deserve then $stdout.puts  editTestGit.repository.deserving_branch?(f)
		end #case
		$stdout.puts editTestGit.repository.git_command('status').inspect
	end #each
end #each
