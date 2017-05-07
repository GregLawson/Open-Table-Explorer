#!/usr/bin/ruby
###########################################################################
#    Copyright (C) 2013-2015 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
# @see http://ruby-doc.org/stdlib-2.0.0/libdoc/optparse/rdoc/OptionParser.html#method-i-make_switch
require_relative '../app/models/command_line.rb'
# require_relative '../app/models/unit.rb'
# require_relative '../app/models/test_executable.rb'
scripting_executable = TestExecutable.new_from_path($PROGRAM_NAME)
require_relative "../app/models/#{scripting_executable.unit.model_basename}"
script_class = Unit::Executing_Unit.model_class?

pp ARGV if $VERBOSE
script = CommandLine.new($PROGRAM_NAME)
pp ARGV if $VERBOSE
pp script.options if $VERBOSE

script.run do
  case CommandLine::Constants::Sub_command
  when :all then
    #			InteractiveBottleneck.all(:model)
    InteractiveBottleneck.all(:test)
    #			InteractiveBottleneck.all(:assertions)
    InteractiveBottleneck.all(:assertions_test)
    InteractiveBottleneck.all(:long_test)
    ShellCommands.new('yard doc').assert_post_conditions
    interactive_bottleneck = InteractiveBottleneck.new($PROGRAM_NAME)
    current_branch = interactive_bottleneck.repository.current_branch_name?
    if current_branch == :passed
      interactive_bottleneck.merge(:master, :passed)
    end # if
    interactive_bottleneck.merge_down(current_branch)
  when :split then
    interactive_bottleneck.split(argv[0], argv[1])
  else CommandLine::Constants::Arguments.each do |f|
    next unless File.exist?(f)
    executable = TestExecutable.new(executable_file: f)
    editor = Editor.new(executable)
    interactive_bottleneck = InteractiveBottleneck.new(executable, editor)
    case CommandLine::Constants::Sub_command
    when :execute then interactive_bottleneck.execute(f)
    when :edit then interactive_bottleneck.editor.edit
    when :test then
      deserving_branch = interactive_bottleneck.test(f)
    #			interactive_bottleneck.merge_down(deserving_branch)
    #			when :loop then interactive_bottleneck.loop(f)
    when :upgrade then interactive_bottleneck.upgrade(f)
    when :best then interactive_bottleneck.best(f)
    when :emacs then interactive_bottleneck.emacs(f)
    when :passed then interactive_bottleneck.repository.stage_files(:passed, [f])
    when :testing then interactive_bottleneck.repository.stage_files(:testing, [f])
    when :edited then interactive_bottleneck.repository.stage_files(:edited, [f])
    when :deserve then
      deserving_branch = interactive_bottleneck.deserving_branch?(f).to_s
      $stdout.puts  interactive_bottleneck.repository.recent_test.inspect
      $stdout.puts  'deserving branch=' + deserving_branch.to_s
    when :minimal then interactive_bottleneck.minimal_edit
    when :related then
      puts interactive_bottleneck.related_files.edit_files.join("\n")
      puts 'diffuse' + interactive_bottleneck.version_comparison + interactive_bottleneck.test_files + interactive_bottleneck.minimal_comparison? if $VERBOSE
    end # case
    # if
    #		scripting_workflow.script_deserves_commit!(:passed)
    #		$stdout.puts interactive_bottleneck.repository.git_command('status --short --branch').inspect
  end # each
  end # case
end # do run
1 # successfully completed
