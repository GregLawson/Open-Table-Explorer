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
require_relative '../../app/models/parse.rb'
class GitReferenceTest < TestCase
  # include DefaultTests
  # include Repository::Examples
  include Commit::ReferenceObjects
  include GitReference::DefinitionalConstants

  def setup
    @temp_repo = Repository.create_test_repository
  end # setup

  def teardown
    Repository.delete_existing(@temp_repo.path)
  end # teardown
	
		def test_head
			assert_kind_of(GitReference, GitReference.head(@temp_repo))
			assert_kind_of(GitReference, GitReference.head(Repository::This_code_repository))
		end # head
		
	
	def test_GitReference_to_s
		assert_equal('HEAD', Head_at_start.to_s, Head_at_start.inspect)
	end # to_s
	
	def test_GitReference_to_sym
		assert_equal(:HEAD, Head_at_start.to_sym, Head_at_start.inspect)
	end # to_s
	
	def test_show_commit
		initialization_string = :HEAD
		repository = Repository::This_code_repository
		run = repository.git_command('show ' + initialization_string.to_s + ' --pretty=oneline  --no-abbrev-commit --no-patch')
		run.assert_post_conditions
		capture = run.output.capture?(Show_commit_regexp)
		assert(capture.success?, capture.inspect)
		sha1 = capture.output[:sha1]
	end # show_commit
	
	def test_sha1
	end # sha1
	
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
end # GitReference

class GitReferenceTest < TestCase
end # Commit