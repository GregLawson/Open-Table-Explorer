#!/usr/bin/ruby
###########################################################################
#    Copyright (C) 2013-2015 by Greg Lawson                                      
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
scripting_executable = TestExecutable.new_from_pathname($0)
scripting_editor = Editor.new(scripting_executable)
scripting_workflow = WorkFlow.new(scripting_executable, scripting_editor)
if File.exists?('.git/MERGE_HEAD') then
	scripting_workflow.merge_conflict_recovery(:MERGE_HEAD)
else
end
# good enough for edited; no syntax error
#scripting_workflow.script_deserves_commit!(:edited)
commands = []
OptionParser.new do |opts|
  opts.banner = "Usage: work_flow.rb --<command> files"

  opts.on("-e", "--[no-]edit", "Edit related files and versions in diffuse") do |e|
    commands+=[:edit] if e
  end
  opts.on("-t", "--[no-]test", "Test, commit. ") do |t|
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
  opts.on("-n", "--[no-]minimal", "edit with minimal comparison. ") do |t|
    commands+=[:minimal] if t
  end
  opts.on("-l", "--[no-]loop", "Test, commit, edit, loop.") do |t|
    commands+=[:loop] if t
  end
  opts.on("-s", "--[no-]split", "split off new class and edit") do |t|
    commands+=[:split] if t
  end
  opts.on("-r", "--[no-]related", "Related files") do |t|
    commands+=[:related] if t
  end
  opts.on("-c", "--[no-]merge-conflict-recovery", "merge_conflict_recovery") do |t|
    commands+=[:merge_conflict_recovery] if t
  end
  
end.parse!

if commands.empty? then
	commands=[:test]
	puts 'No command; assuming test.'
end #if
# good enough for testing; no syntax error
#scripting_workflow.script_deserves_commit!(:testing)

pp commands if $VERBOSE
pp ARGV if $VERBOSE

case ARGV.size # paths after switch removal?
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
#			WorkFlow.all(:model)
			WorkFlow.all(:test)
#			WorkFlow.all(:assertions)
			WorkFlow.all(:assertions_test)
			WorkFlow.all(:long_test)
			ShellCommands.new('yard doc').assert_post_conditions
			work_flow=WorkFlow.new($0)
			current_branch=work_flow.repository.current_branch_name?
			if current_branch==:passed then
				work_flow.merge(:master, :passed) 
			end #if
			work_flow.merge_down(current_branch) 
		when :merge_down then 
			work_flow=WorkFlow.new($0)
			work_flow.merge_down
		when :merge_conflict_recovery then 
			work_flow=WorkFlow.new($0)
			work_flow.merge_conflict_recovery(:MERGE_HEAD)
		when :split then
			work_flow.split(argv[0], argv[1])
	else argv.each do |f|
		executable = TestExecutable.new(executable_file: f)
		editor = Editor.new(executable)
		work_flow=WorkFlow.new(executable, editor)
		case c.to_sym
		when :execute then work_flow.execute(f)
		when :edit then work_flow.editor.edit
		when :test then 
			deserving_branch = work_flow.test(f)
#			work_flow.merge_down(deserving_branch)
		when :loop then work_flow.loop(f)
		when :upgrade then work_flow.upgrade(f)
		when :best then work_flow.best(f)
		when :emacs then work_flow.emacs(f)
		when :passed then work_flow.repository.stage_files(:passed, [f])
		when :testing then work_flow.repository.stage_files(:testing, [f])
		when :edited then work_flow.repository.stage_files(:edited, [f])
		when :deserve then 
			deserving_branch = work_flow.deserving_branch?(f).to_s
			$stdout.puts  work_flow.repository.recent_test.inspect
			$stdout.puts  'deserving branch='+deserving_branch.to_s
		when :minimal then work_flow.minimal_edit
		when :related then
			puts work_flow.related_files.edit_files.join("\n")
			puts "diffuse"+ work_flow.version_comparison + work_flow.test_files + work_flow.minimal_comparison? if $VERBOSE
		end #case
#		scripting_workflow.script_deserves_commit!(:passed)
#		$stdout.puts work_flow.repository.git_command('status --short --branch').inspect
	end #each
	end #case
end #each
1 # successfully completed
