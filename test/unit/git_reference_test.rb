###########################################################################
#    Copyright (C) 2013-2016 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../../app/models/git_reference.rb'
# require_relative '../unit/test_environment'
require_relative '../../app/models/test_environment_test_unit.rb'
require_relative '../../test/assertions/shell_command_assertions.rb'
require_relative '../../app/models/method_model.rb'
# require_relative '../../test/assertions/repository_assertions.rb'
require_relative '../../app/models/parse.rb'
class GitReferenceTest < TestCase
  # include DefaultTests
  # include Repository::Examples
#  include GitReference::Constants
  include BranchReference::Examples
#  include GitReference::Examples
  def setup
    @temp_repo = Repository.create_test_repository
  end # setup

  def teardown
    Repository.delete_existing(@temp_repo.path)
  end # teardown
	
  include BranchReference::DefinitionalConstants
  def test_BranchReference_DefinitionalConstants
    BranchReference.assert_reflog_line(Reflog_line)
    BranchReference.assert_reflog_line(Last_change_line)
    BranchReference.assert_reflog_line(First_change_line)
    Reflog_lines.each do |reflog_line|
      BranchReference.assert_reflog_line(reflog_line)
    end # each
  end # DefinitionalConstants

	def test_dry
		top_level_types = [:String,  :Int, :Float, :Decimal, :Array, :Hash, :Nil, :Symbol, :Class, :True,
			:False, :Date, :DateTime, :Time, :Strict, :Coercible, :Maybe, :Optional, :Bool, :Form, :Json]
		assert_equal(top_level_types, Types.constants)
		type_tree = top_level_types.map do |type_name|
			type = eval('Types::' + type_name.to_s)
			if type.methods.include?(:constants)
				{type_name =>  type.constants}
			else
					{type_name => type.inspect}
			end # if
		end # map
		puts type_tree
	end # dry
	
  def test_new_from_ref
    reflog_line = No_ref_line
    #	Test capture with reflog line having no refs
    message = 'reflog_line = ' + reflog_line.inspect
    capture = reflog_line.capture?(BranchReference::Reflog_line_regexp)
    message += "\ncapture = " + capture.inspect
    refs = reflog_line.split(',')
    message += "\nrefs = " + refs.inspect
    assert_equal(refs[0], '', message)
		
    #	Test method
    br = BranchReference.new_from_ref(reflog_line)
    assert_equal(refs[2].to_sym, br.name, br.inspect)
		
    # Now test one with refs
    reflog_line = Last_change_line
    capture = reflog_line.capture?(BranchReference::Reflog_line_regexp)
    #	Test method

    br = BranchReference.new_from_ref(reflog_line)
    refs = reflog_line.split(',')
    refute_equal(refs[0], '', capture.inspect)
    #			BranchReference.new_from_ref(refs[0]), :time => refs[3]} # unambiguous ref
    assert_equal(refs[0], br.to_s, br.inspect)
    # ?	assert_equal(refs[3] + ',' + refs[4], br.timestamp, br.inspect)
    # ?	assert_equal(refs[3] + ',' + refs[4], br.timestamp, br.inspect)
    assert_operator(Time.rfc2822(refs[4]), :==, br.timestamp, br.inspect) #
		
    new_from_ref = BranchReference.new_from_ref(Reflog_line)
    assert_equal(123, new_from_ref.age.value, Reflog_capture.output.inspect)
    assert_equal(123, new_from_ref[:age].value, Reflog_capture.inspect)
    # ?	assert_match(Regexp::Start_string * BranchReference::Unambiguous_ref_age_pattern * Regexp::End_string, Reflog_reference.age, message)
    # ?	assert_match(Regexp::Start_string * '123' * Regexp::End_string, Reflog_reference.age, message)
    BranchReference.assert_output(Reflog_line)
    BranchReference.assert_output(Last_change_line)
    BranchReference.assert_output(First_change_line)
    BranchReference.new_from_ref(No_ref_line).assert_pre_conditions
    #	assert_equal(nil, capture.output[:ambiguous_branch].nil?)
    BranchReference.new_from_ref(First_change_line).assert_pre_conditions
    BranchReference.new_from_ref(Last_change_line).assert_pre_conditions
    Reflog_reference.assert_pre_conditions
		
		assert_instance_of(Time, br.timestamp, br.inspect)

    branch = :master
    age = 123
		timestamp = Time.now
    br = BranchReference.new(name: branch, age: age, timestamp: timestamp.to_s)
#    assert_equal(br, BranchReference.new_from_ref(Reflog_line))
  end # new_from_ref

  def test_reflog_command_string
    filename = 'log/unit/1.9/1.9.3p194/silence/repository.log'
    repository = This_code_repository
    range = 0..10
    reflog_run = repository.git_command(BranchReference.reflog_command_string(filename, repository, range))
    assert(reflog_run.success?, reflog_run.inspect)
  end # reflog_command_string

  def test_reflog_command_output
    filename = 'log/unit/1.9/1.9.3p194/silence/repository.log'
    repository = This_code_repository
    range = 0..10
    reflog_command_lines = BranchReference.reflog_command_lines(filename, repository, range)
    assert_operator(4, :<, reflog_command_lines.size, reflog_command_lines.inspect)
  end # reflog_command_lines

  def test_reflog?
    filename = 'log/unit/1.9/1.9.3p194/silence/repository.log'
    #	filename = $0
    repository = This_code_repository
    range = 0..10
    #	reflog?(filename).output.split("/n")[0].split(',')[0]
    reflog_run = repository.git_command(BranchReference.reflog_command_string(filename, repository, range))
    #	Reflog_run_executable.assert_post_conditions
    lines = reflog_run.output.split("\n")
    manual_reflog = lines.map do |reflog_line|
      refute_equal('', reflog_line, Reflog_lines.inspect)
      #		BranchReference.assert_reflog_line(reflog_line)
      BranchReference.new_from_ref(reflog_line)
      #		new(capture.output[:ambiguous_branch].to_sym,capture.output[:age].to_i)
    end # map
    reflog = BranchReference.reflog?(filename, This_code_repository)
    #	assert_equal(manual_reflog, reflog, reflog.inspect)
    refute_equal([], reflog, BranchReference.reflog_command_string(filename, repository, range = 0..10).inspect)
    #	reflog.assert_post_conditions
    #	refute_empty(reflog.output)
    ##	lines = reflog.output.split("\n")
    #	assert_instance_of(Array, reflog)
    #	assert_operator(reflog.size, :>,1, reflog)
    #	assert_equal('', reflog[0], lines)
  end # reflog?

  def test_last_change?
    filename = $PROGRAM_NAME
    repository = @temp_repo
    reflog = BranchReference.reflog?(filename, repository)
    assert_equal(nil, BranchReference.last_change?(filename, repository))
    #	assert_includes(Branch.branch_names?(This_code_repository), BranchReference.last_change?(filename, This_code_repository).name)
  end # last_change?

  def test_to_s
    #	BranchReference.assert_output(Reflog_line)
    assert_equal(:master, BranchReference.new_from_ref(Reflog_line).name, Reflog_line)
		reflog_reference = BranchReference.new_from_ref(Reflog_line)
    message = reflog_reference.inspect
		assert_instance_of(Dry::Monads::Maybe::Some, reflog_reference.age, reflog_reference.inspect)
		assert_includes(reflog_reference.age.methods, :value, reflog_reference.inspect)
		assert_instance_of(Fixnum, reflog_reference.age.value, reflog_reference.inspect)
    assert_equal(123, reflog_reference.age.value, message)
    assert_equal('master@{123}', BranchReference.new_from_ref(Reflog_line).to_s)
    assert_equal('master@{123}', Reflog_reference.to_s)
  end # to_s

  def test_assert_reflog_line
    BranchReference.assert_reflog_line(Reflog_line)
    BranchReference.assert_reflog_line(Last_change_line)
    BranchReference.assert_reflog_line(First_change_line)
    BranchReference.assert_reflog_line(No_ref_line)
  end # reflog_line

  def test_assert_output
    BranchReference.assert_output(No_ref_line)
    BranchReference.assert_output(First_change_line)
    BranchReference.assert_output(Reflog_line)
    BranchReference.assert_output(Last_change_line)
  end # assert_output
  def test_Examples
    Reflog_run_executable.assert_post_conditions
    refute_nil(Reflog_lines)
    refute_empty(Reflog_lines, $PROGRAM_NAME + ' has not been added to git yet.')
		refute_nil(First_change_line) 
		refute_nil(Last_change_line) 
    reflog_reference = BranchReference.new_from_ref(Reflog_line)
	end # Examples
end # BranchReference
