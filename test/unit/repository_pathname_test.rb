###########################################################################
#    Copyright (C) 2011-2016 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
# require_relative 'test_environment'
require_relative '../../app/models/test_environment_test_unit.rb'
# require_relative '../../app/models/regexp.rb'
require_relative '../../app/models/test_executable.rb'
class RepositoryPathnameTest < TestCase
  include RepositoryPathname::Examples
  def test_new_from_path
    #	pathname = TestSelf.to_s
    pathname = TestSelf.relative_pathname
    repository = Repository::This_code_repository
    pathname = Pathname.new(pathname).expand_path
    relative_pathname = pathname.relative_path_from(Pathname.new(repository.path))
    RepositoryPathname.new(relative_pathname: relative_pathname, repository: repository)
    assert_equal(TestSelf.to_s, RepositoryPathname.new(relative_pathname: relative_pathname, repository: repository).to_s)
  end # new_from_path

  def test_RepositoryPathname
    refute_empty(TestSelf.relative_pathname.to_s)
    refute_empty(Not_unit.relative_pathname.to_s)
    assert_equal(TestSelf.repository, Repository::This_code_repository)
    assert_equal([:@path], Pathname.new($PROGRAM_NAME).instance_variables)
    assert_instance_of(String, RepositoryPathname.new_from_path($PROGRAM_NAME).path)
  end # values

  # rubocop:disable Metrics/MethodLength
  def test_compare
    assert_equal(0, TestSelf <=> TestSelf)
    assert_equal(0, Not_unit <=> Not_unit)
    assert_equal(0, Not_unit_executable <=> Not_unit_executable)
    assert_equal(0, TestMinimal <=> TestMinimal)
    assert_equal(0, Unit_non_executable <=> Unit_non_executable)

    assert_equal(0, TestSelf.repository <=> Not_unit.repository)
    refute_empty(TestSelf.relative_pathname.to_s)
    refute_empty(Not_unit.relative_pathname.to_s)
    refute_equal(TestSelf.relative_pathname.to_s, Not_unit.relative_pathname.to_s)
    refute_equal(0, TestSelf.relative_pathname.to_s <=> Not_unit.relative_pathname.to_s)
    assert_equal(1, TestSelf <=> Not_unit)
    assert_equal(1, TestSelf <=> Not_unit_executable)
    #    assert_equal(1, TestSelf <=> TestMinimal)
    assert_equal(1, TestSelf <=> Unit_non_executable)
    assert_equal(-1, Not_unit <=> TestSelf)
    assert_equal(-1, Not_unit <=> Not_unit_executable)
    assert_equal(-1, Not_unit <=> TestMinimal)
    assert_equal(-1, Not_unit <=> Unit_non_executable)
    assert_equal(-1, Not_unit_executable <=> TestSelf)
    assert_equal(1, Not_unit_executable <=> Not_unit)
    assert_equal(-1, Not_unit_executable <=> TestMinimal)
    assert_equal(1, Not_unit_executable <=> Unit_non_executable)
    #    assert_equal(-1, TestMinimal <=> TestSelf)
    assert_equal(1, TestMinimal <=> Not_unit)
    assert_equal(1, TestMinimal <=> Not_unit_executable)
    assert_equal(1, TestMinimal <=> Unit_non_executable)
    assert_equal(-1, Unit_non_executable <=> TestSelf)
    assert_equal(1, Unit_non_executable <=> Not_unit)
    assert_equal(-1, Unit_non_executable <=> Not_unit_executable)
    assert_equal(-1, Unit_non_executable <=> TestMinimal)
  end # compare
  # rubocop:enable Metrics/MethodLength

  def test_inspect
    assert_instance_of(String, TestSelf.inspect)
    assert_equal(TestSelf.repository, Repository::This_code_repository)
    assert_equal(TestSelf.relative_pathname.to_s, TestSelf.inspect)
  end # inspect

  def test_expand_path
    assert_instance_of(Pathname, TestSelf.expand_path)
  end # expand_path

  def test_to_s
    assert_includes(TestSelf.methods, :to_s)
    assert_instance_of(String, TestSelf.to_s)
    assert_equal(TestSelf.expand_path.to_s, TestSelf.to_s)
  end # to_s

  def test_lint_command_string
    assert_match(/rubocop /, TestSelf.lint_command_string)
    assert_match(/rubocop/, Not_unit.lint_command_string)
    assert_match(/rubocop/, Not_unit_executable.lint_command_string)
    assert_match(/rubocop/, TestMinimal.lint_command_string)
    assert_match(/rubocop/, Unit_non_executable.lint_command_string)
    assert_instance_of(Hash, JSON[TestSelf.lint_output])
  end # lint_command_string

  def test_lint_out_file
    assert(File.exist?(TestSelf.lint_out_file.dirname), TestSelf.lint_out_file.dirname.to_s)
    refute_empty(Dir['log/lint/*'])
    assert(TestSelf.lint_out_file.dirname.directory?)
    refute(TestSelf.lint_out_file.directory?, TestSelf.lint_out_file.stat.inspect)
    refute_empty(Dir['log/lint/**/*.json'])
    # assert_empty(Dir['log/lint/**/*.*'] - Dir['log/lint/**/*.json'])
    assert(File.exist?(TestSelf.lint_out_file), TestSelf.lint_out_file.to_s)
  end # lint_out_file

  # rubocop:disable Metrics/MethodLength
  def test_lint_output
    assert_instance_of(String, TestSelf.lint_output)
    assert_instance_of(String, Not_unit.lint_output)
    assert_instance_of(String, Not_unit_executable.lint_output)
    assert_instance_of(String, TestMinimal.lint_output)
    assert_instance_of(String, Unit_non_executable.lint_output)

    assert_operator(0, :<, TestSelf.lint_output.size, TestSelf.lint_output.inspect)
    assert_operator(0, :<, Not_unit.lint_output.size)
    assert_operator(0, :<, Not_unit_executable.lint_output.size)
    assert_operator(0, :<, TestMinimal.lint_output.size)
    assert_operator(0, :<, Unit_non_executable.lint_output.size)

    assert_instance_of(Hash, JSON[TestSelf.lint_output])
    assert_instance_of(Hash, JSON[Not_unit.lint_output])
    assert_instance_of(Hash, JSON[Not_unit_executable.lint_output])
    assert_instance_of(Hash, JSON[TestMinimal.lint_output])
    assert_instance_of(Hash, JSON[Unit_non_executable.lint_output])

    #    assert_equal('', TestSelf.lint_run.errors)
    #    assert_equal('', Not_unit.lint_run.errors)
    #    assert_equal('', TestMinimal.lint_run.errors)
    #    assert_equal('', Unit_non_executable.lint_run.errors)
    #    assert_equal('', Not_unit_executable.lint_run.errors)

    #    TestSelf.lint_run.assert_post_conditions
  end # lint_output

  def test_lint_json
    assert_equal(1, TestSelf.lint_json['summary']['inspected_file_count'], TestSelf.lint_json['summary'])
    assert_equal(1, Not_unit.lint_json['summary']['inspected_file_count'], Not_unit.lint_json)
    assert_equal(1, Not_unit_executable.lint_json['summary']['inspected_file_count'], Not_unit_executable.lint_command_string)
    assert_equal(1, Not_unit_executable.lint_json['summary']['inspected_file_count'], Not_unit_executable.lint_json)
    assert_equal(1, TestMinimal.lint_json['summary']['inspected_file_count'])
    assert_equal(1, Unit_non_executable.lint_json['summary']['inspected_file_count'])

    assert_equal(0, Not_unit.lint_json['summary']['offense_count'], Not_unit.lint_json)
    assert_equal(0, Not_unit_executable.lint_json['summary']['offense_count'], Not_unit_executable.lint_command_string)
    assert_equal(0, Not_unit_executable.lint_json['summary']['offense_count'], Not_unit_executable.lint_json)
    assert_equal(0, TestMinimal.lint_json['summary']['offense_count'], TestMinimal.lint_json.ruby_lines_storage)
    assert_operator(10, :<, Unit_non_executable.lint_json['summary']['offense_count'], Unit_non_executable.lint_json)
    assert_equal(1, TestSelf.lint_json['files'].size, TestSelf.lint_json['files'])
    assert_include(TestSelf.lint_json['files'][0].keys, 'offenses', TestSelf.lint_json['files'])
    assert_equal(%w(convention warning), TestSelf.lint_json['files'][0]['offenses'].map { |o| o['severity'] }.uniq, TestSelf.lint_json['files'])
    assert_equal(TestSelf.relative_pathname.to_s, TestSelf.lint_json['files'][0]['path'], TestSelf.lint_json['files'])
  end # lint_json

  def test_lint_warnings
    assert_equal([], Not_unit.lint_warnings)
    assert_equal([], TestMinimal.lint_warnings)
    #    assert_equal(['Syntax'], Unit_non_executable.lint_warnings.map { |o| o['cop_name'] }.uniq, Unit_non_executable.lint_warnings)
    assert_equal([], Not_unit_executable.lint_warnings)
    existing_cops = TestSelf.lint_warnings.map { |o| o['cop_name'] }.uniq
    unexpected_cops = existing_cops - RepositoryPathname::Lint_warning_priorities
    message = TestSelf.lint_warnings.select do |offense|
      offense[:unexpected] = unexpected_cops.include?(offense['cop_name'])
      assert_include(existing_cops, offense['cop_name'])
      #      assert_include(RepositoryPathname::Lint_warning_priorities, offense['cop_name'], offense)
      unexpected_cops.include?(offense['cop_name'])
    end.join("\n") # if
    assert_empty(unexpected_cops, message)
  end # lint_warnings

  def test_lint_unconventional
    unsorted = TestSelf.lint_json['files'][0]['offenses'].select { |o| o['severity'] == 'convention' }
    sorted = unsorted.sort do |x, y|
      assert_respond_to(RepositoryPathname::Lint_convention_priorities, :index)
      comparison = if RepositoryPathname::Lint_convention_priorities.include?(x['cop_name'])
                     if RepositoryPathname::Lint_convention_priorities.include?(y['cop_name'])
                       RepositoryPathname::Lint_convention_priorities.index(x['cop_name']) <=> RepositoryPathname::Lint_convention_priorities.index(y['cop_name'])
                     else
                       +1
                     end # if
                   else
                     if RepositoryPathname::Lint_convention_priorities.include?(y['cop_name'])
                       -1
                     else
                       x['cop_name'] > y['cop_name'] # if all else fails, use alphabetical order
                     end # if
                   end # if
      #      assert_include(RepositoryPathname::Lint_convention_priorities, x['cop_name'], x.inspect)
      #      assert_include(RepositoryPathname::Lint_convention_priorities, y['cop_name'], y.inspect)
      comparison
    end # sort

    assert_instance_of(Array, TestSelf.lint_unconventional, TestSelf.lint_unconventional)
    #    assert_include(TestSelf.lint_unconventional, 'Metrics/LineLength', TestSelf.lint_unconventional)
    assert_equal([], Not_unit.lint_unconventional)
    assert_equal([], TestMinimal.lint_unconventional)
    #    assert_equal([], Unit_non_executable.lint_unconventional.map { |o| o['cop_name'] }.uniq)
    assert_equal([], Not_unit_executable.lint_unconventional)
    unexpected_cops = TestSelf.lint_unconventional.map { |o| o['cop_name'] }.uniq - RepositoryPathname::Lint_convention_priorities
    assert_empty(unexpected_cops, TestSelf.lint_unconventional) # flag new cops
  end # lint_unconventional
  # rubocop:enable Metrics/MethodLength

  def test_lint_top_unconventional
    refute_equal(RepositoryPathname::Lint_convention_priorities[0], TestSelf.lint_top_unconventional['cop_name'], TestSelf.lint_top_unconventional)
  end # lint_top_unconventional
end # RepositoryPathname
