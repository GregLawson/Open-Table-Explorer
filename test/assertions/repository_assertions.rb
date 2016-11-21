###########################################################################
#    Copyright (C) 2013 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
# @see http://grit.rubyforge.org/
# assert_includes(Module.constants, :ShellCommands)
# assert_includes(Module.constants, :FilePattern)
# assert_includes(Module.constants, :Unit)
# assert_includes(Module.constants, :Capture)
# assert_includes(Module.constants, :Branch)
# assert_includes(Module.constants, :Repository)
# assert_includes(Repository.constants, :DefinitionalConstants)
require_relative '../../app/models/repository.rb'
# assert_includes(Module.constants, :ShellCommands)
# assert_includes(Module.constants, :FilePattern)
# assert_includes(Module.constants, :Unit)
# assert_includes(Module.constants, :Capture)
# assert_includes(Module.constants, :Branch)
# assert_includes(Module.constants, :Repository)
# assert_includes(Repository.constants, :DefinitionalConstants)
# assert_includes(Repository.constants, :DefinitionalConstants)
class Repository # <Grit::Repo
  require_relative '../../app/models/assertions.rb'
  module Assertions
    module ClassMethods
      def assert_pre_conditions
      end # assert_pre_conditions

      def assert_post_conditions
      end # assert_post_conditions
    end # ClassMethods
    def assert_pre_conditions
      # ?	assert_pathname_exists(@path)
      # ?	assert_pathname_exists(@path+'.git/')
      # ?	assert_pathname_exists(@path+'.git/logs/')
      # ?	assert_pathname_exists(@path+'.git/logs/refs/')
    end # assert_pre_conditions

    def assert_post_conditions
    end # assert_post_conditions

    def assert_nothing_to_commit(message = '')
      status = @grit_repo.status
      message += "git status=#{inspect}\n@grit_repo.status=#{@grit_repo.status.inspect}"
      #	assert_equal({}, status.added, 'added '+message)
      #	assert_equal({}, status.changed, 'changed '+message)
      # S	assert_equal({}, status.deleted, 'deleted '+message)
    end # assert_nothing_to_commit

    def assert_something_to_commit(message = '')
      message += "git status=#{inspect}\n@grit_repo.status=#{@grit_repo.status.inspect}"
      #	assert(something_to_commit?, message)
    end # assert_something_to_commit
  end # Assertions
  include Assertions
  extend Assertions::ClassMethods
  Repository.assert_pre_conditions
  module Examples
    # assert_equal(Repository::Examples, self)
    # assert_includes(Repository.constants, :DefinitionalConstants)
    include Repository::DefinitionalConstants
    include Repository::ReferenceObjects
    #	This_code_repository.assert_pre_conditions
    Unique_repository_directory_pathname = Repository.timestamped_repository_name?
    Empty_Repo_path = Unique_repository_directory_pathname
    Modified_path = Empty_Repo_path + '/README'
    #	This_code_repository.assert_pre_conditions
  end # Examples
end # Repository
# assert_includes(Repository.constants, :DefinitionalConstants)
