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
class FileArgumentTest < TestCase
  include FileArgument::Examples
  def test_coerce
  end # coerce

  def test_FileArgument_Examples
  end # Examples

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

    # assert_equal('', TestSelf.errors)
    # assert_equal('', Not_unit.errors)
    # assert_equal('', TestMinimal.errors)
    # assert_equal('', Unit_non_executable.errors)
    # assert_equal('', Not_unit_executable.errors)
  end # lint_output
  # rubocop:enable Metrics/MethodLength

  def test_unit_file_type
    assert_equal(:unit, TestSelf.unit_file_type)
    assert_equal(:unit, TestMinimal.unit_file_type)
    assert_equal(:non_unit, Not_unit.unit_file_type)
    assert_nil(Not_unit.pattern)
    refute_nil(Unit_non_executable.pattern, Unit_non_executable.inspect)
    assert_equal(:unit_log, Unit_non_executable.unit_file_type)
    assert_equal(:data_sources_dir, Not_unit_executable.unit_file_type)
  end # unit_file_type

  def test_unit_file?
    assert_equal(true, TestSelf.unit_file?)
    assert_equal(true, TestMinimal.unit_file?)
    assert_equal(true, Unit_non_executable.unit_file?)
    assert_equal(false, Not_unit.unit_file?)
    assert_equal(true, Not_unit_executable.unit_file?)
  end # unit_file?

  def generatable_unit_file?
    assert_equal(true, TestSelf.generatable_unit_file?)
    assert_equal(true, TestMinimal.generatable_unit_file?)
    assert_equal(false, Unit_non_executable.generatable_unit_file?)
    assert_equal(false, Not_unit.generatable_unit_file?)
    assert_equal(false, Not_unit_executable.generatable_unit_file?)
  end # generatable_unit_file?

  def test_lint_unit
    TestSelf.unit.edit_files.each do |p|
      assert_instance_of(Pathname, p)
      file = FileArgument.new(argument_path: p)
      if file.generatable_unit_file?
        file.argument_path.lint_output
      end # if
    end # each
    TestSelf.lint_unit
  end # lint_unit
end # FileArgument
