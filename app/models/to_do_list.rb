###########################################################################
#    Copyright (C) 2013-2014 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../../test/assertions/branch_assertions.rb'
class ToDoList
  module ClassMethods
  end # ClassMethods
  extend ClassMethods
  module Constants
    Hex_number = /[0-9a-f]+/
    SED_SEQUENCE_EDITOR = "sed -i -re 's/^pick /e /' | git rebase -i".freeze
    COLA_SEQUENCE_EDITOR = '/usr/share/git-cola/bin/git-xbase'.freeze # blank so far
    EMACS_SEQUENCE_EDITOR = 'emacs'.freeze
    DEFAULT_SEQUENCE_EDITOR = EMACS_SEQUENCE_EDITOR
    # git-cola interface to rebase not working yet
    GIT_COLA_TRACE = 'full'.freeze # (for commands and status) or trace (to cola console widget) or unset (no output) or other values (commands)
  end # Constants
  include Constants
  attr_reader :branch, :onto
  # onto origin/<branch> for default
  #        String =>previous commit starts rebase ('--root' possible)
  def initialize(branch, onto = nil)
    if branch.instance_of?(Branch)
      @branch = branch
    elsif branch.instance_of?(Symbol)
      raise "branch=#{branch.inspect} should be type Branch."
    else
      raise "branch=#{branch.inspect} should be type Branch."
    end # if
    @onto = onto
  end # initialize

  def todo_list
    git_command('git shortlog ' + find_origin + '..' + @branch.to_s).output
  end # todo_list

  def flip_start_fixup
    todo_cache = todo_list # relatively expensive call
    squashable_list = todo_cache[0]
    todo_cache.cons(2) do |consecutive_lines|
      previous_commit = consecutive_lines[0]
      fixup_header = consecutive_lines[1]
      if fixup_header != previous_commit # change
        squashable_list << fixup_header.gsub(/fixup! |squash! /, '') # delete header on first
      else
        squashable_list << consecutive_lines[1]
      end # if
    end # map
  end # flip_start_fixup

  def fixup_until_fail
    run = git_command('git rebase --continue')
  end # fixup_until_fail

  def rebase_editor?(editor = DEFAULT_SEQUENCE_EDITOR)
    { 'GIT_SEQUENCE_EDITOR' => editor.to_s }
  end # rebase_editor?

  def rebase!(sequence_editor = rebase_editor?)
    # rebase only on clean working directory
    unless @branch.repository.something_to_commit?
      @run = ShellCommands.named(env: sequence_editor, command: command_line_rebase_string?, opts: { chdir: branch.repository.path }) # only on configured remote
      if @run.success?
      else
        @abort_status = @branch.repository.git_command('rebase --abort').puts
      end # if
    end # if
    self
  end # rebase!

  def rebase_branch!
    if remotes?.include?(current_branch_name?)
      git_command('rebase --interactive origin/' + current_branch_name?).assert_post_conditions.output.split("\n")
    else
      puts current_branch_name?.to_s + ' has no remote branch in origin.'
    end # if
  end # rebase!

  def puts
    puts @run.inspect
    puts @branch.repository.state?.inspect
  end # puts

  def command_line_rebase_string?
    command_string = 'git rebase ' # beginning
    if @branch.repository.interactive == :interactive
      command_string += '--interactive '
    end # if
    command_string += @branch.to_s
    if @onto.nil?
      command_string += if @branch.remote_branch.nil?
                          ' --root'
                        else
                          ' --onto ' + @branch.remote_branch.to_s
                        end
    elsif @onto.instance_of?(Fixnum)
      command_string += ' --onto ' + @branch.to_s + '~' + @onto.to_s
    else # normal String ref
      command_string += ' --onto ' + @onto.to_s
    end # if
  end # command_line_rebase_string?
  module Assertions
    include AssertionsModule
    module ClassMethods
      include AssertionsModule
      def assert_pre_conditions(message = '')
        message += "In assert_pre_conditions, self=#{inspect}"
      end # assert_pre_conditions

      def assert_post_conditions(message = '')
        message += "In assert_post_conditions, self=#{inspect}"
      end # assert_post_conditions
    end # ClassMethods
    def assert_pre_conditions(message = '')
    end # assert_pre_conditions

    def assert_post_conditions(message = '')
    end # assert_post_conditions
  end # Assertions
  include Assertions
  extend Assertions::ClassMethods
  # self.assert_pre_conditions
  module Examples
    include Constants
    include Branch::Examples
    Test_rebase = ToDoList.new(Branch::Examples::Empty_repo_master_branch)
    Test_rebase_4 = ToDoList.new(Branch::Examples::Empty_repo_master_branch, 4)
    Test_rebase_passed = ToDoList.new(Branch::Examples::Empty_repo_passed_branch)
    Executing_rebase = ToDoList.new(Branch::Examples::Executing_master_branch)
    Executing_rebase_4 = ToDoList.new(Branch::Examples::Executing_master_branch, 4)
    Executing_rebase_passed = ToDoList.new(Branch::Examples::Executing_passed_branch)
  end # Examples
end # ToDoList
