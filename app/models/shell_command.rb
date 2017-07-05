###########################################################################
#    Copyright (C) 2013-2016 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'open3'
require 'shellwords.rb'
require_relative 'log.rb'
require 'pathname'
require 'virtus'
require 'timeout'
module Shell
  class Base
    module DefinitionalConstants # constant parameters of the type (suggest all CAPS)
      Default_run = lambda do |_process, _attribute|
        begin
          _process.start
        rescue StandardError => exception_object_raised
          _process.errors[:rescue_start] = exception_object_raised
        end # begin
      end # Default_run
    end # DefinitionalConstants
    include DefinitionalConstants
    module ClassMethods
      include Shellwords
      def assemble_hash_command(command)
        command_array = []
        command.each_pair do |key, word|
          case key
          when :command then command_array << Shellwords.escape(word)
          when :in then
            raise "Input file '#{word}' does not exist." unless File.exist?(word)
            command_array << Shellwords.escape(word)
          when :out then command_array << Shellwords.escape(word)
          when :inout then command_array << Shellwords.escape(word)
          when :glob then
            raise "Input pathname glob '#{word}' does not exist." if !Dir(word) == []
            command_array << Shellwords.escape(word)
          when :environment then command_array << word
          else
            command_array << word
          end # case
        end # each_pair
        command_array.join(' ')
      end # assemble_hash_command

      def assemble_array_command(command)
        command.map do |e|
          if e.instance_of?(Array)
            assemble_array_command(e)
          elsif e.instance_of?(Hash)
            assemble_hash_command(e)
          elsif e.instance_of?(Pathname)
            e.to_s
          elsif /[ \/.]/ =~ e # pathnames
            Shellwords.escape(e)
          elsif /[$;&|<>]/ =~ e # shell special characters
            e
          else # don't know
            e
          end # if
        end.join(' ') # map
      end # assemble_array_command

      def assemble_command_string(command)
        if command.instance_of?(Array)
          assemble_array_command(command)
        elsif command.instance_of?(Hash)
          assemble_hash_command(command)
        else
          command
        end # if
      end # assemble_command_string
    end # ClassMethods
    extend ClassMethods
    include Virtus.value_object
    values do
      attribute :command_string, String
      attribute :env, Hash, default: {}
      attribute :opts, Hash, default: {}
      attribute :errors, Hash, default: {}
      attribute :cached_run, Object, default: nil
      attribute :start_time, Time, default: Time.now
      attribute :elapsed_time, Float
    end # values
  end # Shell::Base

  class Server < Base
    #    include Shell::Base
    extend Shell::Base::ClassMethods
    module DefinitionalClassMethods
    end # DefinitionalClassMethods
    extend DefinitionalClassMethods
    include Virtus.value_object
    values do
      attribute :timeout, Float, default: 0.0 # no timeout
      attribute :stdin, File, default: nil
      attribute :stdout, File, default: nil
      attribute :stderr, File, default: nil
      attribute :wait_thr, Object, default: nil
      attribute :output, String, default: nil
    end # values

    def select
      IO.select([stdout], [stdin], [stderr], 0.01)
    end # select

    def start
      @stdin, @stdout, @stderr, @wait_thr = Open3.popen3(@command_string)
      #      @stdin, @stdout, @stderr, @wait_thr = Open3.popen3(@env, @command_string, @opts)
      self # allows command chaining
    end # start

    def process_status
      raise 'process_status undefined until server started.' if @wait_thr.nil?
      @wait_thr.value
    end # process_status

    def exitstatus
      @wait_thr.value.exitstatus
    end # process_status

    def wait
      @process_status = @wait_thr.value # Process::Status object returned.
      close
      self # allows command chaining
    end # wait

    def tee
      Timeout.timeout(@timeout) do
        @output = @stdout.read
        puts @output
      end # Timeout
    rescue Timeout::Error => exception_object_raised
      @errors[:rescue_tee] = exception_object_raised
    end # tee

    def close
      @stdin.close # stdin, stdout and stderr should be closed explicitly in this form.
      begin
        Timeout.timeout(@timeout) do
          @process_status = @wait_thr.value # Process::Status object returned.
        end # Timeout
      rescue Timeout::Error => exception_object_raised
        @errors[:rescue_close] = exception_object_raised
      end # begin/rescue block
      @output = @stdout.read
      @stdout.close
      stderr = @stderr.read
      unless stderr.empty?
        @errors[:stderr] = @stderr.read
      end # if
      @stderr.close
      self # allows command chaining
    end # close

    def success?
      if process_status.nil?
        false
      else
        process_status.exitstatus == 0 # & ~@accumulated_tolerance_bits # explicit toleration
      end # if
    end # success

    module Constructors # such as alternative new methods
      include Shell::Base::DefinitionalConstants
    end # Constructors
    extend Constructors
    module ReferenceObjects # constant objects of the type (e.g. default_objects)
      include Shell::Base::DefinitionalConstants
    end # ReferenceObjects
    include ReferenceObjects

    module Assertions
      module ClassMethods
        def assert_pre_conditions(message = '')
          message += "In assert_pre_conditions, self=#{inspect}"
          # assert_nested_and_included('Shell::Server::Assertions', self)
          #	assert_nested_and_included(:Constants, self)
          #	assert_nested_and_included(:Assertions, self)
          #          assert_includes(Process.included_modules, :Waiter)
          self
        end # assert_pre_conditions

        def assert_post_conditions(message = '')
          message += "In assert_post_conditions, self=#{inspect}"
          self
        end # assert_post_conditions

        def assert_pipe(stream, message = '')
          assert_instance_of(IO, stream, message)
        end # pipe

        def assert_readable(stream)
          assert_equal(false, stream.closed?, message) # hangs
        rescue StandardError => exception_object_raised
          assert_equal('', exception_object_raised.class.name)
          # begin
        end # readable

        def assert_writable(stream)
          begin
            assert_equal(false, stream.eof?, message) # hangs
          rescue StandardError => exception_object_raised
            assert_instance_of(IOError, exception_object_raised)
            assert_include(exception_object_raised.methods, :inspect)
            assert_include(Exception.instance_methods(false), :message)
            assert_include(exception_object_raised.methods, :message)
            assert_equal('not opened for reading', exception_object_raised.message)
          end # begin
          begin
            assert_equal(false, stream.closed?, message) # hangs
          rescue StandardError => exception_object_raised
            assert_equal('', exception_object_raised.class.name)
          end # begin
        end # writable
      end # ClassMethods
      def assert_pre_conditions(_message = '')
        message += "In assert_pre_conditions, self=#{inspect}"
        self # return for command chaining
      end # assert_pre_conditions

      def assert_post_conditions(message = '')
        #        message += "In assert_post_conditions, self=#{inspect}"
        puts unless success? && @errors.empty?
        assert_empty(@errors, message + 'expected errors to be empty\n')
        #				assert_equal(0, process_status.exitstatus & ~@accumulated_tolerance_bits, message)
        assert_not_nil(@errors, 'expect @errors to not be nil.')
        #        assert_not_nil(process_status)
        #				assert_instance_of(Process::Status, process_status)

        self # return for command chaining
      end # assert_post_conditions

      def assert_started(_message = '')
        #        message += "In assert_post_conditions, self=#{inspect}"
        assert_instance_of(Process::Waiter, wait_thr)
        assert_instance_of(Process::Status, process_status)
        Shell::Server.assert_pipe(stdin)
        Shell::Server.assert_pipe(stdout)
        Shell::Server.assert_pipe(stderr)
        assert_equal(false, stdin.closed?, message)
        assert_equal(false, stdout.closed?, message)
        assert_equal(false, stderr.closed?, message)

        selection = IO.select([@stdout], [@stdin], [@stderr], 15)
        assert_equal([@stdout], selection[0])
        assert_equal([@stdin], selection[1])
        assert_equal([], selection[2])
        Shell::Server.assert_writable(@stdin)
        #        assert_equal(false, stdin.eof?, message)
        assert_equal(false, stdout.eof?, message) # hangs
        #        assert_equal(false, stderr.eof?, message)
        self # return for command chaining
      end # assert_started

      def assert_ended(_message = '')
        assert_equal([:pid], wait_thr.class.instance_methods(false), wait_thr.inspect)
        assert_instance_of(IO, stdin, message)
        assert_instance_of(IO, stdout, message)
        assert_instance_of(IO, stderr, message)
        assert_equal(true, stdin.closed?, message)
        assert_equal(true, stdout.closed?, message)
        assert_equal(true, stderr.closed?, message)

        assert_equal(0, wait_thr.value.exitstatus, wait_thr.inspect)
        assert_include(wait_thr.value.class.instance_methods(false), :exitstatus, wait_thr.inspect)
        assert_equal(0, wait_thr.value.exitstatus, wait_thr.value)
        assert_instance_of(Fixnum, wait_thr.value.pid, wait_thr.value)
        assert_equal(wait_thr.value.exitstatus, wait_thr.value.to_i, wait_thr.value)
        assert_equal(0, wait_thr.value.to_i, wait_thr.value)
        assert_match(/pid [0-9]+ exit [0-9]+/, wait_thr.value.to_s, wait_thr.value)
        assert_match(/#{wait_thr.value.to_s}/, wait_thr.value.inspect, wait_thr.value)
        assert_equal(false, wait_thr.value.stopped?, wait_thr.value)
        assert_equal(nil, wait_thr.value.stopsig, wait_thr.value)
        assert_equal(false, wait_thr.value.signaled?, wait_thr.value)
        assert_equal(nil, wait_thr.value.termsig, wait_thr.value)
        assert_equal(true, wait_thr.value.exited?, wait_thr.value)
        assert_equal(true, wait_thr.value.success?, wait_thr.value)
        assert_equal(false, wait_thr.value.coredump?, wait_thr.value)
        assert_instance_of(Hash, wait_thr.value.as_json, wait_thr.value)
        assert_instance_of(Fixnum, wait_thr.value.as_json[:pid], wait_thr.value)
        assert_instance_of(Fixnum, wait_thr.value.as_json[:exitstatus], wait_thr.value)
        assert_equal(true, wait_thr.value.==(0), wait_thr.value)
        assert_equal(0, wait_thr.value.&(127), wait_thr.value)
        assert_equal(0, wait_thr.value.>>(3), wait_thr.value)
        self # return for command chaining
      end # assert_started
    end # Assertions
    include Assertions
    extend Assertions::ClassMethods
    # self.assert_pre_conditions
  end # Server

  class Command < Server
    #    include Shell::Base
    extend Shell::Base::ClassMethods
    module DefinitionalConstants # constant parameters of the type (suggest all CAPS)
      Default_run = lambda do |_process, _attribute|
        begin
          start
          close
        rescue StandardError => exception_object_raised
          @errors[:rescue] = exception_object_raised
        end # begin
      end # Default_run
    end # DefinitionalConstants
    include DefinitionalConstants
    module DefinitionalClassMethods
    end # DefinitionalClassMethods
    extend DefinitionalClassMethods
    include Virtus.value_object
    values do
    end # values

    module Constructors # such as alternative new methods
      include DefinitionalConstants
    end # Constructors
    extend Constructors
    module ReferenceObjects # constant objects of the type (e.g. default_objects)
      include DefinitionalConstants
    end # ReferenceObjects
    include ReferenceObjects
    module Examples # usually constant objects of the type (easy to understand (perhaps impractical) examples for testing)
      include DefinitionalConstants
      include ReferenceObjects
      Hello_world = Shell::Command.new(command_string: 'echo "Hello World"')
      Example_output = "1 2;3 4\n".freeze
      COMMAND_STRING = 'echo "1 2;3 4"'.freeze
      EXAMPLE = Shell::Command.new(command_string: COMMAND_STRING)
      Guaranteed_existing_directory = File.expand_path(File.dirname($PROGRAM_NAME))
      Cd_command_array = ['cd', Guaranteed_existing_directory].freeze
      Cd_command_hash = { command: 'cd', in: Guaranteed_existing_directory }.freeze
      Guaranteed_existing_basename = File.basename($PROGRAM_NAME)
      Redirect_command = ['ls', Guaranteed_existing_basename, '>', 'blank in filename.shell_command'].freeze
      Redirect_command_string = 'ls ' + Shellwords.escape(Guaranteed_existing_basename) + ' > ' + Shellwords.escape('blank in filename.shell_command')
      Relative_command = ['ls', Guaranteed_existing_basename].freeze
      Bad_status = Shell::Command.new(command_string: '$?=1')
      Error_message_run = Shell::Command.new(command_string: 'ls happyHappyFailFail.junk')
    end # Examples
  end # Command

  class Ssh
    #    include Shell::Base
    extend Shell::Base::ClassMethods
    module ClassMethods
      def agent_processes
      end # agent_processes
    end # ClassMethods
    extend ClassMethods
    module Constants
    end # Constants
    include Constants
    attr_reader :user

    def initialize(user)
      @user = user
    end # initialize

    def [](command_on_remote)
      command_string = 'ssh ' + @user + ' ' + command_on_remote
      ShellCommands.new(command_string)
      end # []
    module Assertions
      module ClassMethods
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
      Central = Ssh.new('greg@172.31.42.104')
    end # Examples
  end # Ssh
end # Shell

class FileDependancy
  #  include Shell::Base
  extend Shell::Base::ClassMethods
  include Virtus.value_object
  values do
    attribute :input_paths, Array, default: []
    attribute :chdir, Pathname, default: nil # current working directory
    attribute :output_paths, Array, default: []
    attribute :errors, Hash, default: {}
    attribute :cached_run, Object, default: nil
  end # values

  def input_updated?
    input_missing = @input_paths.map { |p| !Pathname.new(p).exist? }.any?
    output_missing = @output_paths.map { |p| !Pathname.new(p).exist? }.any?
    if input_missing
      false
    elsif output_missing
      true
    else
      input_times = @input_paths.map { |p| Pathname.new(p).mtime }
      output_times = @output_paths.map { |p| Pathname.new(p).mtime }
      if input_times.empty?
        true
      elsif output_times.empty?
        true
      else
        input_times.max > output_times.min
      end # if
    end # if
  end # input_updated?

  def explain_updated
    input_missing = @input_paths.map { |p| !Pathname.new(p).exist? }.any?
    output_missing = @output_paths.map { |p| !Pathname.new(p).exist? }.any?
    if input_missing
      'if inputs are missing, there can\'t be an update yet.'
    elsif output_missing
      'if there are missing outputs, an update is required to create them.'
    else
      input_times = @input_paths.map { |p| Pathname.new(p).mtime }
      output_times = @output_paths.map { |p| Pathname.new(p).mtime }
      if input_times.empty?
        'input files are missing'
      elsif output_times.empty?
        'output files are missing'
      else
        input_times.inspect + ' > ' + output_times.inspect
      end # if
    end # if
  end # explain_updated

  def delete_output_files!
    (@output_paths - @input_paths).each do |path| # don't delete files that are both input and output
      if File.exist?(path)
        Pathname.new(path).delete
      end # if
    end # each
  end # delete_output_files!
  module Examples
    Pwd = FileDependancy.new(command_string: 'pwd')
    Chdir = FileDependancy.new(command_string: 'pwd', chdir: '/tmp')
    Touch_create_path = '/tmp/junk' + Time.now.to_s
    Touch_command = ['touch', Touch_create_path].freeze
    Touch_create = FileDependancy.new(command_string: Touch_command, output_paths: [Touch_create_path])
    Touch = FileDependancy.new(input_paths: [Touch_create_path], command_string: Touch_command, output_paths: [Touch_create_path])
    Cat = FileDependancy.new(input_paths: ['/dev/null'], command_string: 'cat /dev/null')
    Touch_fail = FileDependancy.new(command_string: Touch_command, output_paths: ['/tmp/junk2'])
    Cat_fail = FileDependancy.new(input_paths: ['/dev/null2'], command_string: 'cat /dev/null')
  end # Examples
end # FileDependancy

class FileIPO < FileDependancy # IPO = Input, Processing, and Output
  include Virtus.value_object
  values do
    attribute :command_string, String
  end # values

  def run
    @errors = {} # each run resets errors
    @input_paths.each do |path|
      unless File.exist?(path)
        @errors[path] = :input_does_not_exist
      end # if
    end # each
    delete_output_files! # no problem if you have faith in input and output lists
    @cached_run = if @chdir.nil?
                    ShellCommands.new(@command_string)
                  else
                    ShellCommands.new(@command_string, chdir: @chdir)
    end # if
    #	@errors[:process_status] = @cached_run.process_status
    if @cached_run.process_status.exitstatus != 0
      @errors[:exitstatus] = @cached_run.process_status.exitstatus
    end # if
    unless @cached_run.errors.empty?
      errors[:stderr] = @cached_run.errors
    end # if
    @output_paths.each do |path|
      if File.exist?(path)
        update_time = Pathname.new(path).mtime
        update_delay = update_time - @cached_run.start_time

        if update_delay < -0.0035 # rounding differences
          message = 'output_not_updated. update_time = ' + update_time.to_s + ' < ' + @cached_run.start_time.to_s + '(@cached_run.start_time)'
          message += 'update_time < @cached_run.start_time = ' + (update_time < @cached_run.start_time).to_s
          message += ' delay = ' + update_delay.to_s
          @errors[path] = message
        end # if
      else
        @errors[path] = :output_does_not_exist
      end # if
    end # each
    self # allows command chaining
  end # run

  def success?
    if @cached_run.process_status.exitstatus != 0
      false
    #	elsif errors[:stderr] != '' then
    #		false
    elsif @errors.values - [:input_does_not_exist, :output_does_not_exist] != @errors.values
      false
    else
      true
    end # if
  end # success?
  module Examples
    Pwd = FileIPO.new(command_string: 'pwd')
    Chdir = FileIPO.new(command_string: 'pwd', chdir: '/tmp')
    Touch_create_path = '/tmp/junk' + Time.now.to_s
    Touch_command = ['touch', Touch_create_path].freeze
    Touch_create = FileIPO.new(command_string: Touch_command, output_paths: [Touch_create_path])
    Touch = FileIPO.new(input_paths: [Touch_create_path], command_string: Touch_command, output_paths: [Touch_create_path])
    Cat = FileIPO.new(input_paths: ['/dev/null'], command_string: 'cat /dev/null')
    Touch_fail = FileIPO.new(command_string: Touch_command, output_paths: ['/tmp/junk2'])
    Cat_fail = FileIPO.new(input_paths: ['/dev/null2'], command_string: 'cat /dev/null')
  end # Examples
end # FileIPO

class ShellCommands
  #  include Shell::Base
  extend Shell::Base::ClassMethods
  attr_reader :command_string, :output, :errors, :process_status, :elapsed_time
  # execute same command again (also called by new).
  def execute
    @start_time = Time.now
    info '@command=' + @command.inspect
    info '@command_string=' + @command_string.inspect
    Open3.popen3(@env, @command_string, @opts) do |stdin, stdout, stderr, wait_thr|
      stdin.close # stdin, stdout and stderr should be closed explicitly in this form.
      @output = stdout.read
      stdout.close
      @errors = stderr.read
      stderr.close
      @process_status = wait_thr.value # Process::Status object returned.
      @elapsed_time = Time.now - @start_time
    end
    self # allows command chaining
  rescue StandardError => exception_object_raised
    message = 'rescue exception in Shell#execute' + exception_object_raised.inspect
    message += "\n" + caller.join("\n")
    #    $stdout.puts message
    info '@command=' + @command.inspect
    info '@command_string=' + @command_string.inspect
    if @errors.nil?
      @errors = exception_object_raised.inspect
    else
      @errors += exception_object_raised.inspect
    end # if
  end # execute
  # prefer command as array since each element is shell escaped.
  # Most common need for shell excape is spaces in pathnames (a common GUI style)
  attr_reader :argument_array, :env, :command, :opts, :command_string, :elapsed_time, :start_time
  def initialize(*command)
    if command.size >= 1 # empty command is primarily for testing
      parse_argument_array(command)
      execute # do it first time, to repeat call execute
      @accumulated_tolerance_bits = 0x00 # all errors reported (not tolerated)
      if $VERBOSE.nil?
      elsif $VERBOSE
        $stdout.puts trace # -W2
      else
        $stdout.puts inspect(:echo_command) # -W1
      end # if
    end # if
  end # initialize

  # Allow Process.spawn options and environment to be passed.
  def parse_argument_array(argument_array)
    @argument_array = argument_array
    case argument_array.size
    when 3 then
      @env = argument_array[0]
      @command = argument_array[1]
      @opts = argument_array[2]
    when 2 then
      if argument_array[0].instance_of?(Hash)
        if argument_array[1].instance_of?(Hash)
          @env = {}
          @command = argument_array[0]
          @opts = argument_array[1]
        else
          @env = argument_array[0]
          @command = argument_array[1]
          @opts = {}
        end # if
      else # command is not a Hash
        @env = {}
        @command = argument_array[0]
        @opts = argument_array[1]
      end # if
    when 1 then
      @env = {}
      @command = argument_array[0]
      @opts = {}
    end # case
    @command_string = ShellCommands.assemble_command_string(@command)
  end # parse_argument_array

  def success?
    if @process_status.nil?
      false
    else
      @process_status.exitstatus == 0 # & ~@accumulated_tolerance_bits # explicit toleration
    end # if
  end # success

  def clear_error_message!(tolerated_status)
    @errors = ''
    @accumulated_tolerance_bits |= tolerated_status # accumulated_tolerance_bits
    self # for command chaining
  end # clear_error_message!

  def force_success(tolerated_status)
    warn(@errors) if $VERBOSE
    modified_self = clone
    modified_self.clear_error_message!(tolerated_status)
    modified_self # for command chaining
  end # force_success

  def tolerate_status(tolerated_status = 1)
    if @process_status.exitstatus == tolerated_status
      force_success(tolerated_status)
    else
      self # for command chaining
    end # if
  end # tolerate_status

  def tolerate_error_pattern(tolerated_error_pattern = /^warning/)
    if tolerated_error_pattern.match(@errors)
      force_success(0xFF) # tolerate all error codes
    else
      self # for command chaining
    end # if
  end # tolerate_error_pattern

  def tolerate_status_and_error_pattern(tolerated_status = 1, tolerated_error_pattern = /^warning/)
    if @process_status.exitstatus == tolerated_status && tolerated_error_pattern.match(@errors)
      force_success(tolerated_status)
    else
      self # for command chaining
    end # if
  end # tolerate_status_and_error_message

  def inspect(echo_command = @errors != '' || !success?)
    ret = ''
    if echo_command
      ret += "$ #{@command_string}\n"
      ret += "@env=#{@env.inspect}\n" if $VERBOSE
      ret += "@command=#{@command.inspect}\n" if $VERBOSE
      ret += "@opts=#{@opts.inspect}\n" if $VERBOSE
    end # if
    unless @errors.empty?
      ret += "@errors=#{@errors.inspect}\n"
      if $VERBOSE && !@command_string.empty?
        ret += "Shellwords.split(@command_string).inspect=#{Shellwords.split(@command_string).inspect}\n"
      end # if
    end # if
    unless success?
      ret += "@process_status=#{@process_status.inspect}\n"
    end # if
    if @output.nil?
      ret
    else
      ret + @output.to_s
    end # if
  end # inspect

  def puts
    $stdout.puts inspect(:echo_command)
    self # return for command chaining
  end # puts

  def trace
    $stdout.puts inspect(:echo_command)
    shorter_callers = caller.grep(/^[^\/]/)
    $stdout.puts shorter_callers.join("\n")
    self # return for command chaining
  end # trace
  # require_relative '../../test/assertions.rb'
  module Assertions
    def assert_pre_conditions(_message = '')
      self # return for command chaining
    end # assert_pre_conditions

    def assert_post_conditions(message = '')
      message += "self=#{inspect(true)}"
      #      puts unless success? && @errors.empty?
      assert_empty(@errors, message + 'expected errors to be empty\n')
      assert_equal(0, @process_status.exitstatus & ~@accumulated_tolerance_bits, message)
      assert_not_nil(@errors, 'expect @errors to not be nil.')
      assert_not_nil(@process_status)
      assert_instance_of(Process::Status, @process_status)

      self # return for command chaining
    end # assert_post_conditions
  end # Assertions
  include Assertions
end # ShellCommands
