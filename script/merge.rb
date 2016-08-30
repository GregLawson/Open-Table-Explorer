#!/usr/bin/ruby
###########################################################################
#    Copyright (C) 2013-2015 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../app/models/unit.rb' # before command_line
require_relative "../app/models/#{Unit::Executable.model_basename}"
require_relative '../app/models/command_line.rb'
scripting_executable = TestExecutable.new_from_path($PROGRAM_NAME)
require_relative "../app/models/#{scripting_executable.unit.model_basename}"
script_class = RailsishRubyUnit::Executable.model_class?

script = CommandLine.new(executable: $PROGRAM_NAME, unit_class: script_class)
pp ARGV if $VERBOSE
pp script.options if $VERBOSE

script.run do

# CommandLine::Script_command_line.sub_command
	merge_hash = {interactive: :interactive, repository: Repository::This_code_repository}
  if script.sub_command == :trial_merge then
		merge_hash[:source_commit] = Branch.new(name: script.arguments[0])
		merge_hash[:target_branch_name] = Repository::This_code_repository.current_branch_name?
		merge = Merge.new(merge_hash)
		puts merge.trial_merge.inspect
	else
		merge_hash[:source_commit] = Branch.new(name: Repository::This_code_repository.current_branch_name?)
		merge_hash[:target_branch_name] = script.arguments[0].to_sym
		case script.sub_command
		when :merge_down then
			merge = Merge.new(merge_hash)
			merge.merge_down
		when :merge_conflict_recovery then
			merge = Merge.new(merge_hash)
			merge.merge_conflict_recovery(:MERGE_HEAD)
		else script.arguments.each do |f|
			merge = Merge.new(merge_hash)
			next unless File.exist?(f)
			executable = TestExecutable.new(executable_file: f)
			editor = Editor.new(executable)
			case CommandLine::Constants::Sub_command
			when :passed then merge.repository.stage_files(:passed, [f])
			when :testing then merge.repository.stage_files(:testing, [f])
			when :edited then merge.repository.stage_files(:edited, [f])
			end # case
			# if
			#		scripting_workflow.script_deserves_commit!(:passed)
			#		$stdout.puts merge.repository.git_command('status --short --branch').inspect
		end # each
		end # case
	end # if
end # do run
1 # successfully completed
