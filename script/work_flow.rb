#!/usr/bin/ruby
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
  opts.on("-a", "--[no-]all", "All files tested ") do |t|
    commands+=[:all] if t
  end
  opts.on("-l", "--[no-]minimal", "edit with minimal comparison. ") do |t|
    commands+=[:minimal] if t
  end
  opts.on("-r", "--[no-]related", "Related files") do |t|
    commands+=[:related] if t
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
commands.each do |c|
	case c.to_sym
		when :all then 
			WorkFlow.new($0).all(:test)
			WorkFlow.new($0).all(:assertions_test)
			WorkFlow.new($0).all(:long_test)
	else argv.each do |f|
		work_flow=WorkFlow.new(f)
		case c.to_sym
		when :execute then work_flow.execute(f)
		when :edit then work_flow.edit
		when :test then work_flow.test(f)
		when :upgrade then work_flow.upgrade(f)
		when :downgrade then work_flow.downgrade(f)
		when :best then work_flow.best(f)
		when :emacs then work_flow.emacs(f)
		when :passed then work_flow.repository.stage_files(:passed, [f])
		when :testing then work_flow.repository.stage_files(:testing, [f])
		when :edited then work_flow.repository.stage_files(:edited, [f])
		when :deserve then 
			$stdout.puts  'deserving branch='+work_flow.repository.deserving_branch?(f).to_s
			$stdout.puts  work_flow.repository.recent_test.inspect
		when :minimal then work_flow.minimal_edit
		when :related then
			puts work_flow.related_files.inspect
			puts "diffuse"+ work_flow.version_comparison + work_flow.test_files + work_flow.minimal_comparison?

		end #case
		$stdout.puts work_flow.repository.git_command('status --short --branch').inspect
	end #each
	end #case
end #each
