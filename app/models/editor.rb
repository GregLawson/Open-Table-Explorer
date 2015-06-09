###########################################################################
#    Copyright (C) 2013-15 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'unit.rb'
#require_relative 'repository.rb'
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
# parametized by related files, repository, branch_number, executable
# record error_score, recent_test, time
attr_reader :executable, :unit_maturity
def initialize(executable)
#specific_file,
#	related_files = Unit.new_from_path?(specific_file),
#	repository = Repository.new(FilePattern.repository_dir?, :interactive))
	@executable = executable
	@specific_file = @executable.executable_file
	@unit_maturity = UnitMaturity.new(@executable.repository, executable.unit)
	@repository = @executable.repository
	index = UnitMaturity::Branch_enhancement.index(@executable.repository.current_branch_name?)
	if index.nil? then
		@branch_index = UnitMaturity::First_slot_index
	else
		@branch_index = index
	end # if
end # initialize
def version_comparison(files = nil)
	if files.nil? then
		files = [@repository.log_path?(@executable.unit.model_test_pathname?)].concat(@executable.unit.edit_files)
	end # if
	ret = files.map do |f|
		goldilocks(f)
	end # map
	ret.join(' ')
end # version_comparison
def goldilocks(filename, middle_branch = @repository.current_branch_name?.to_sym)
	if File.exists?(filename) then
		current_index = UnitMaturity.branch_index?(middle_branch)
		left_index, right_index = @unit_maturity.bracketing_versions?(filename, current_index)
		relative_filename = Pathname.new(File.expand_path(filename)).relative_path_from(Pathname.new(Dir.pwd)).to_s
		ret = ' -t '
		if left_index.nil? then
			ret += " #{relative_filename} "
		else
			ret += "#{UnitMaturity.revison_tag?(left_index)} #{relative_filename} "
		end # if
		ret += relative_filename
		if right_index.nil? then
			ret += " #{relative_filename} "
		else
			ret += " #{UnitMaturity.revison_tag?(right_index)} #{relative_filename}"
		end # if
	else
		ret = ''
	end # if
	ret += ' -r ' + BranchReference.last_change?(filename, repository) + ' ' + filename
end # goldilocks
def test_files(edit_files = @executable.unit.edit_files)
	pairs = @executable.unit.functional_parallelism(edit_files).map do |p|

		' -t ' + p.map do |f|
			Pathname.new(f).relative_path_from(Pathname.new(Dir.pwd)).to_s

		end.join(' ') # map
	end # map
	pairs.join(' ')
end # test_files
def minimal_comparison?
	if @executable.unit.edit_files == [] then
		unit_pattern = FilePattern.new_from_path(_FILE_)
	else
		unit_pattern = FilePattern.new_from_path(@executable.unit.edit_files[0])
	end # if
	unit_name = unit_pattern.unit_base_name
	FilePattern::Constants::Patterns.map do |p|
		pattern = FilePattern.new(p)
		pwd = Pathname.new(Dir.pwd)
		default_test_class_id = @executable.unit.default_test_class_id?.to_s
		min_path = Pathname.new(pattern.path?('minimal' + default_test_class_id))
		unit_path = Pathname.new(pattern.path?(unit_name))
#		path = Pathname.new(start_file_pattern.pathname_glob(@executable.unit.model_basename)).relative_path_from(Pathname.new(Dir.pwd)).to_s
#		puts "File.exists?('#{min_path}')==#{File.exists?(min_path)}, File.exists?('#{path}')==#{File.exists?(path)}" if $VERBOSE
		if File.exists?(min_path)  then
			' -t ' + unit_path.relative_path_from(pwd).to_s + ' ' + 
				min_path.relative_path_from(pwd).to_s
		end # if
	end.compact.join # map
end # minimal_comparison
def edit(context = nil)
	if context.nil? then
	else
	end # if
	@repository.recent_test.puts if !@repository.recent_test.nil?
	if @executable.unit.nil? || @executable.unit.edit_files.empty? then
		command_string = 'diffuse' + version_comparison([@specific_file])
	else
		command_string = 'diffuse' + version_comparison + test_files
	end # if
	puts command_string if $VERBOSE
	edit = @repository.shell_command(command_string)
	edit = edit.tolerate_status_and_error_pattern(0, /Warning/)
	status =edit
#	status.assert_post_conditions
end # edit
def split(executable, new_base_name)
	new_unit = Unit.new(new_base_name, project_root_dir)
	@executable.unit.edit_files. map do |f|
		pattern_name = FilePattern.find_by_file(f)
		split_tab += ' -t ' + f + new_unit.pattern?(pattern_name)
		@repository.shell_command('cp ' + f +  new_unit.pattern?(pattern_name))
	end #map
	edit = @repository.shell_command('diffuse' + version_comparison + test_files + split_tab)
	puts edit.command_string
	edit.assert_post_conditions
end # split
def minimal_edit
	edit = @repository.shell_command('diffuse' + version_comparison + test_files + minimal_comparison?)
	puts edit.command_string
	edit.assert_post_conditions
end # minimal_edit
def emacs(executable = @executable.unit.model_test_pathname?)
	emacs = @repository.shell_command('emacs --no-splash ' + @executable.unit.edit_files.join(' '))
	puts emacs.command_string
	emacs.assert_post_conditions
end # emacs
require_relative '../../test/assertions.rb'
module Assertions

module ClassMethods

def assert_pre_conditions
end # assert_pre_conditions
def assert_post_conditions
#	assert_pathname_exists(TestFile, "assert_post_conditions")
end # assert_post_conditions
end # ClassMethods
def assert_pre_conditions
	assert_not_nil(@executable.unit)
	assert_not_empty(@executable.unit.edit_files, "assert_pre_conditions, @test_environmen=#{@test_environmen.inspect}, @executable.unit.edit_files=#{@executable.unit.edit_files.inspect}")
	assert_kind_of(Grit::Repo, @repository.grit_repo)
	assert_respond_to(@repository.grit_repo, :status)
	assert_respond_to(@repository.grit_repo.status, :changed)
end # assert_pre_conditions
def assert_post_conditions
	odd_files = Dir['/home/greg/Desktop/src/Open-Table-Explorer/test/unit/*_test.rb~HEAD*']
	assert_empty(odd_files, 'Editor#assert_post_conditions')
end # assert_post_conditions
end # Assertions
include Assertions
extend Assertions::ClassMethods
# TestEditor.assert_pre_conditions
include Constants
module Examples
TestExecutable = TestExecutable.new_from_pathname(File.expand_path($PROGRAM_NAME))
#TestFile = File.expand_path($PROGRAM_NAME)
TestEditor = Editor.new(TestExecutable)
include Constants
end # Examples
include Examples
end # Editor
