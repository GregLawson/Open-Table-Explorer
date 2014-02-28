#!/usr/bin/ruby
###########################################################################
#    Copyright (C) 2013-2014 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
# @see http://ruby-doc.org/stdlib-2.0.0/libdoc/optparse/rdoc/OptionParser.html#method-i-make_switch
require 'pp'
require_relative '../app/models/work_flow.rb'
require_relative '../app/models/command_line.rb'
require_relative '../app/models/unit.rb'
scripting_workflow=WorkFlow.new($0)
# good enough for edited; no syntax error
scripting_workflow.script_deserves_commit!(:edited)
commands = []
script = CommandLineScript.new($0)
script.add_option('Edit.', :edit)
script.add_option('Test.', :test)
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
unit_files = Unit.new($0)

case ARGV.size
when 0 then # scite testing defaults command and file
	puts "unit --<command> <file>"
	this_file=File.expand_path(__FILE__)
	argv=[this_file] # incestuous default test case for scite
	commands=[:test]
else
	argv=ARGV
end #case
argv.each do |f|
	work_flow=WorkFlow.new(f)
	commands.each do |c|
		case c.to_sym
		when :execute then work_flow.execute
		when :edit then work_flow.edit
		when :test then work_flow.test
		when :upgrade then work_flow.upgrade
		when :downgrade then work_flow.downgrade
		when :merge_down then work_flow.merge_down
		end #case
	end #each
end #each
WorkFlow::Git_status.execute.puts
