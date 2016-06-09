###########################################################################
#    Copyright (C) 2013-16 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'unit.rb'
# require_relative 'repository.rb'
require_relative 'unit_maturity.rb'
require_relative '../../app/models/test_executable.rb'
class Editor
  module Constants
  end # Constants
  include Constants
  module ClassMethods
    include Constants
  end # ClassMethods
  extend ClassMethods
  # Define related (unit) versions
  # Use as current, lower/upper bound, branch history
  # parametized by related files, repository, branch_number, test_executable
  # record error_score, recent_test, time
  attr_reader :test_executable, :unit_maturity
  def initialize(test_executable)
    # specific_file,
    #	related_files = Unit.new_from_path(specific_file),
    #	repository = Repository.new(FilePattern.repository_dir?, :interactive))
    @test_executable = test_executable
    @specific_file = @test_executable.argument_path
    @unit_maturity = UnitMaturity.new(@test_executable.repository, test_executable.unit)
    index = Branch::Branch_enhancement.index(@test_executable.repository.current_branch_name?)
    @branch_index = if index.nil?
                      Branch::First_slot_index
                    else
                      index
                    end # if
  end # initialize

  def version_comparison(files = nil)
    if files.nil?
      files = [@test_executable.log_path?(nil)].concat(@test_executable.unit.edit_files)
    end # if
    ret = files.map do |f|
      goldilocks(f)
    end # map
    ret.join(' ')
  end # version_comparison

  def goldilocks(filename, middle_branch = @test_executable.repository.current_branch_name?.to_sym)
    if File.exist?(filename)
      current_index = Branch.branch_index?(middle_branch)
      left_index, right_index = @unit_maturity.bracketing_versions?(filename, current_index)
      relative_filename = Pathname.new(File.expand_path(filename)).relative_path_from(Pathname.new(Dir.pwd)).to_s
      ret = ' -t '
      ret += if left_index.nil?
               " #{relative_filename} "
             else
               "#{Branch.revison_tag?(left_index)} #{relative_filename} "
             end # if
      ret += relative_filename
      ret += if right_index.nil?
               " #{relative_filename} "
             else
               " #{Branch.revison_tag?(right_index)} #{relative_filename}"
             end # if
    else
      ret = ''
    end # if
    ret += ' -r ' + BranchReference.last_change?(filename, @test_executable.repository).to_s + ' ' + filename.to_s
  end # goldilocks

  def test_files(edit_files = @test_executable.unit.edit_files)
    pairs = edit_files.map do |file| 
			symbol = FilePattern.find_name_from_path(file)
			parallel_symbol = @test_executable.unit.parallel_display[symbol]
			if parallel_symbol.nil?
				nil
			else
				parallel_file = @test_executable.unit.pathname_pattern?(parallel_symbol)
				' -t ' + Pathname.new(parallel_file).expand_path.relative_path_from(Pathname.new(Dir.pwd)).to_s +
					' ' + Pathname.new(file).expand_path.relative_path_from(Pathname.new(Dir.pwd)).to_s
			end # if
    end.compact # map
    pairs.join(' ')
  end # test_files

  def minimal_comparison?
    if @test_executable.unit.edit_files == []
      unit_pattern = FilePattern.new_from_path(__FILE__)
    else
      unit_pattern = FilePattern.new_from_path(@test_executable.unit.edit_files[0])
    end # if
    unit_name = unit_pattern.unit_base_name
    FilePattern::Patterns.map do |p|
      pattern = FilePattern.new(p)
      pwd = Pathname.new(Dir.pwd)
      default_test_class_id = @test_executable.unit.default_test_class_id?.to_s
      min_path = Pathname.new(pattern.path?('minimal' + default_test_class_id))
      unit_path = Pathname.new(pattern.path?(unit_name))
      #		path = Pathname.new(start_file_pattern.pathname_glob(@test_executable.unit.model_basename)).relative_path_from(Pathname.new(Dir.pwd)).to_s
      #		puts "File.exists?('#{min_path}')==#{File.exists?(min_path)}, File.exists?('#{path}')==#{File.exists?(path)}" if $VERBOSE
      if File.exist?(min_path)
        ' -t ' + unit_path.relative_path_from(pwd).to_s + ' ' +
          min_path.relative_path_from(pwd).to_s
      end # if
    end.compact.join # map
  end # minimal_comparison

  def edit
    @test_executable.repository.recent_test.puts unless @test_executable.repository.recent_test.nil?
    if @test_executable.unit.nil? || @test_executable.unit.edit_files.empty?
      command_string = 'diffuse' + version_comparison([@specific_file])
    else
      command_string = 'diffuse' + version_comparison + test_files
    end # if
    puts command_string unless $VERBOSE.nil?
    status = @test_executable.repository.shell_command(command_string)
    status = edit.tolerate_status_and_error_pattern(0, /Warning/)
    status # .assert_post_conditions
  end # edit

  def split(_test_executable, new_base_name)
    new_unit = Unit.new(new_base_name, project_root_dir)
    @test_executable.unit.edit_files. map do |f|
      pattern_name = FilePattern.find_by_file(f)
      split_tab += ' -t ' + f + new_unit.pattern?(pattern_name)
      @test_executable.repository.shell_command('cp ' + f + new_unit.pattern?(pattern_name))
    end # map
    status = @test_executable.repository.shell_command('diffuse' + version_comparison + test_files + split_tab)
    puts status.command_string
    status # .assert_post_conditions
  end # split

  def minimal_edit
    status = @test_executable.repository.shell_command('diffuse' + version_comparison + test_files + minimal_comparison?)
    puts status.command_string
    status # .assert_post_conditions
  end # minimal_edit

  def emacs(_test_executable = @test_executable.unit.model_test_pathname?)
    status = @test_executable.repository.shell_command('emacs --no-splash ' + @test_executable.unit.edit_files.join(' '))
    puts status.command_string
    status # .assert_post_conditions
  end # emacs
  # require_relative '../../app/models/assertions.rb'
  module Assertions
    module ClassMethods
      def assert_pre_conditions
      end # assert_pre_conditions

      def assert_post_conditions
        #	assert_pathname_exists(TestEditor.test_executable.argument_path, "assert_post_conditions")
      end # assert_post_conditions
    end # ClassMethods
    def assert_pre_conditions
      # sometimes	refute_nil(@test_executable.unit)
      #	refute_empty(@test_executable.unit.edit_files, "assert_pre_conditions, @test_environmen=#{@test_environmen.inspect}, @test_executable.unit.edit_files=#{@test_executable.unit.edit_files.inspect}")
      #	assert_kind_of(Grit::Repo, @test_executable.repository.grit_repo)
      #	assert_respond_to(@test_executable.repository.grit_repo, :status)
      #	assert_respond_to(@test_executable.repository.grit_repo.status, :changed)
    end # assert_pre_conditions

    def assert_post_conditions
      odd_files = Dir['/home/greg/Desktop/src/Open-Table-Explorer/test/unit/*_test.rb~HEAD*']
      #	assert_empty(odd_files, 'Editor#assert_post_conditions')
    end # assert_post_conditions
  end # Assertions
  include Assertions
  extend Assertions::ClassMethods
  # TestEditor.assert_pre_conditions
  include Constants
  module Examples
    EditorTestExecutable = TestExecutable.new_from_path(File.expand_path($PROGRAM_NAME))
    TestEditor = Editor.new(EditorTestExecutable)
    include Constants
  end # Examples
  include Examples
end # Editor
