#!/usr/bin/ruby
###########################################################################
#    Copyright (C) 2013-2015 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
# @see http://ruby-doc.org/stdlib-2.0.0/libdoc/optparse/rdoc/OptionParser.html#method-i-make_switch
require 'optparse'
require 'ostruct'
require 'pp'
require_relative '../app/models/interactive_bottleneck.rb'
require_relative '../app/models/command_line.rb'
scripting_executable = TestExecutable.new_from_pathname($0)
scripting_editor = Editor.new(scripting_executable)
scripting_workflow = InteractiveBottleneck.new(scripting_executable, scripting_editor)
if File.exists?('.git/MERGE_HEAD') then
	scripting_workflow.merge_conflict_recovery(:MERGE_HEAD)
else
end
# good enough for edited; no syntax error
#scripting_workflow.script_deserves_commit!(:edited)
commands = []
OptionParser.new do |opts|
  opts.banner = "Usage: interactive_bottleneck.rb --<command> files"

  opts.on("-e", "--[no-]edit", "Edit related files and versions in diffuse") do |e|
    commands+=[:edit] if e
  end
  opts.on("-d", "--[no-]merge-down", "Test downgraded related files in git branches") do |d|
    commands+=[:merge_down] if d
  end
  opts.on("-u", "--[no-]upgrade", "Test upgraded related files in git branches") do |u|
    commands+=[:upgrade] if u
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
	puts "interactive_bottleneck --<command> <file>"
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
			interactive_bottleneck=WorkFlow.new($0)
			current_branch=interactive_bottleneck.repository.current_branch_name?
			if current_branch==:passed then
				interactive_bottleneck.merge(:master, :passed) 
			end #if
			interactive_bottleneck.merge_down(current_branch) 
		when :merge_down then 
			interactive_bottleneck=WorkFlow.new($0)
			interactive_bottleneck.merge_down
		when :merge_conflict_recovery then 
			interactive_bottleneck=WorkFlow.new($0)
			interactive_bottleneck.merge_conflict_recovery(:MERGE_HEAD)
		when :split then
			interactive_bottleneck.split(argv[0], argv[1])
	else argv.each do |f|
		executable = TestExecutable.new(executable_file: f)
		editor = Editor.new(executable)
		interactive_bottleneck=WorkFlow.new(executable, editor)
		case c.to_sym
		when :execute then interactive_bottleneck.execute(f)
		when :edit then interactive_bottleneck.editor.edit
		when :test then 
			deserving_branch = interactive_bottleneck.test(f)
#			interactive_bottleneck.merge_down(deserving_branch)
		when :loop then interactive_bottleneck.loop(f)
		when :upgrade then interactive_bottleneck.upgrade(f)
		when :best then interactive_bottleneck.best(f)
		when :emacs then interactive_bottleneck.emacs(f)
		when :passed then interactive_bottleneck.repository.stage_files(:passed, [f])
		when :testing then interactive_bottleneck.repository.stage_files(:testing, [f])
		when :edited then interactive_bottleneck.repository.stage_files(:edited, [f])
		when :deserve then 
			deserving_branch = interactive_bottleneck.deserving_branch?(f).to_s
			$stdout.puts  interactive_bottleneck.repository.recent_test.inspect
			$stdout.puts  'deserving branch='+deserving_branch.to_s
		when :minimal then interactive_bottleneck.minimal_edit
		when :related then
			puts interactive_bottleneck.related_files.edit_files.join("\n")
			puts "diffuse"+ interactive_bottleneck.version_comparison + interactive_bottleneck.test_files + interactive_bottleneck.minimal_comparison? if $VERBOSE
		end #case
#		scripting_workflow.script_deserves_commit!(:passed)
#		$stdout.puts interactive_bottleneck.repository.git_command('status --short --branch').inspect
	end #each
	end #case
end #each
1 # successfully completed
