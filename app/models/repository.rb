###########################################################################
#    Copyright (C) 2013-2016 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'dry-types'
module Types
  include Dry::Types.module
end # Types

class FileStatus < Dry::Types::Value
  module DefinitionalClassMethods # if reference by DefinitionalConstants or not referenced
    # The following decoding is from man git status
    def file_change(status_char)
      case status_char
      when ' ' then :unmodified
      when 'M' then :modified
      when 'A' then :added
      when 'D' then :deleted
      when 'R' then :renamed
      when 'C' then :copied
      when 'U' then :updated_but_unmerged
      when '?' then :untracked
      when '!' then :ignored
         end # case
    end # file_change

    def match_possibilities?(one_letter_code, possibilities)
      if possibilities.size == 1
        one_letter_code == possibilities
      else
        if possibilities[1..-2].index(one_letter_code).nil?
          false
        else
          true
        end # if
      end # if
    end # match_possibilities?

    def match_two_possibilities?(two_letter_code, index, work_tree)
      match_possibilities?(two_letter_code[0..0], index) &&
        match_possibilities?(two_letter_code[1..1], work_tree)
    end # match_two_possibilities?

    def normal_status_descriptions(two_letter_code)
      if match_two_possibilities?(two_letter_code, ' ', '[MD]') then 'not updated'
      elsif match_two_possibilities?(two_letter_code, 'M', '[ MD]') then 'updated in index'
      elsif match_two_possibilities?(two_letter_code, 'A', '[ MD]') then 'added to index'
      elsif match_two_possibilities?(two_letter_code, 'D', ' [ M]') then 'deleted from index'
      elsif match_two_possibilities?(two_letter_code, 'R', '[ MD]') then 'renamed in index'
      elsif match_two_possibilities?(two_letter_code, 'C', '[ MD]') then 'copied in index'
      elsif match_two_possibilities?(two_letter_code, '[MARC]', ' ') then 'index and work tree matches'
      elsif match_two_possibilities?(two_letter_code, '[ MARC]', 'M') then 'work tree changed since index'
      elsif match_two_possibilities?(two_letter_code, '[ MARC]', 'D') then 'deleted in work tree'
      else
        unmerged_status_descriptions	= unmerged_status_descriptions(two_letter_code)
        if unmerged_status_descriptions.nil?
          index = file_change(two_letter_code[0..0])
          work_tree = file_change(two_letter_code[1..1])
          if index == work_tree
            'both ' + work_tree.to_s
          else
            index.to_s + ' then ' + work_tree.to_s
          end # if
        else
          unmerged_status_descriptions
        end # if
      end # if
    end # normal_status_descriptions

    def unmerged_status_descriptions(two_letter_code)
      case two_letter_code
      when 'DD' then 'unmerged, both deleted'
      when 'AU' then 'unmerged, added by us'
      when 'UD' then 'unmerged, deleted by them'
      when 'UA' then 'unmerged, added by them'
      when 'DU' then 'unmerged, deleted by us'
      when 'AA' then 'unmerged, both added'
      when 'UU' then 'unmerged, both modified'
      end # case
    end # unmerged_status_descriptions
  end # DefinitionalClassMethods
  extend DefinitionalClassMethods

  module DefinitionalConstants # constant parameters in definition of the type (suggest all CAPS)
    Commitable = [:modified, :added, :deleted, :renamed, :copied].freeze
  end # DefinitionalConstants
  include DefinitionalConstants

  attribute :index, Types::Strict::Symbol
  attribute :work_tree, Types::Strict::Symbol
  attribute :file, Types::Strict::String

  module Constructors # such as alternative new methods
    #    include DefinitionalConstants
    def new_from_status_line(status_line)
      file = status_line[3..-1]
      FileStatus.new(index: FileStatus.file_change(status_line[0..0]), work_tree: FileStatus.file_change(status_line[1..1]), file: file)
    end # new_from_status_line
  end # Constructors
  extend Constructors

  module ReferenceObjects # example constant objects of the type (e.g. default_objects)
    #    include DefinitionalConstants
  end # ReferenceObjects
  include ReferenceObjects

  def log_file?
    @file[-4..-1] == '.log'
  end # log_file?

  def description
    FileStatus.normal_status_descriptions(@index.to_s + @work_tree.to_s)
  end # description

  def needs_commit?
    Commitable.include?(@work_tree) ||
      Commitable.include?(@index) ||
      merge_conflict?
  end # needs_commit?

  def merge_conflict?
    @work_tree == :updated_but_unmerged ||
      @index == :updated_but_unmerged
  end # merge_conflict?
end # FileStatus

# assert_includes(Module.constants, :ShellCommands)
# refute_includes(Module.constants, :FilePattern)
# refute_includes(Module.constants, :Unit)
# assert_includes(Module.constants, :Capture)
# assert_includes(Module.constants, :Branch)
# @see http://grit.rubyforge.org/
require 'grit' # sudo gem install grit
# partial API at @see less /usr/share/doc/ruby-grit/API.txt
# code in @see /usr/lib/ruby/vendor_ruby/grit
# assert_includes(Module.constants, :ShellCommands)
# assert_includes(Module.constants, :FilePattern)
# assert_includes(Module.constants, :Unit)
# assert_includes(Module.constants, :Capture)
# assert_includes(Module.constants, :Branch)
# refute_includes(Module.constants, :Unit)
require_relative 'unit.rb'
# assert_includes(Module.constants, :Unit)
# assert_includes(Module.constants, :FilePattern)
require_relative 'shell_command.rb'
# assert_includes(Module.constants, :ShellCommands)
# require_relative 'global.rb'
# refute_includes(Module.constants, :Capture)
require_relative 'parse.rb'
# assert_includes(Module.constants, :Capture)
# refute_includes(Module.constants, :Branch)
# require_relative 'branch.rb'
# assert_includes(Module.constants, :Branch)
# refute_includes(Module.constants, :Repository)
class Repository
  module DefinitionalConstants # constant parameters in definition of the type (suggest all CAPS)
    Repository_Unit = Unit.new_from_path(__FILE__)
    Root_directory = FilePattern.project_root_dir?(__FILE__)
    Source = File.dirname(Root_directory) + '/'
    README_start_text = 'Minimal repository.'.freeze
  end # DefinitionalConstants
  include DefinitionalConstants

  module DefinitionalClassMethods # if reference by DefinitionalConstants or not referenced
    include DefinitionalConstants
    def git_command(git_command, repository_dir)
      ShellCommands.new('git ' + ShellCommands.assemble_command_string(git_command), chdir: repository_dir)
    end # git_command
  end # DefinitionalClassMethods
  extend DefinitionalClassMethods

  attr_reader :path, :grit_repo
  def initialize(path)
    if path.to_s[-1, 1] != '/'
      path = path.to_s + '/'
    end # if
    #    @url = path
    @path = path.to_s
    #    puts '@path=' + @path if $VERBOSE
    @grit_repo = Grit::Repo.new(@path)
  end # initialize

  def ==(rhs)
    @path == rhs.path
  end # equal

  def <=>(rhs) # allow sort
    repository_compare = @path <=> rhs.path
    if repository_compare.nil?
      if @path.nil?
        if rhs.path.nil?
          0
        else
          -1
        end # if
      else
        if rhs.path.nil?
          +1
        else
          -1
        end # if
      end # if
    else
      repository_compare
    end # if
  end # compare

  def shell_command(command, working_directory = @path)
    ShellCommands.new(command, chdir: working_directory)
  end # shell_command

  def git_command(git_subcommand)
    Repository.git_command(git_subcommand, @path)
  end # git_command

  # def inspect
  #	git_command('status --short --branch').output
  # end #inspect
  def corruption_fsck
    git_command('fsck')
  end # corruption

  def corruption_rebase
    #	git_command("rebase")
  end # corruption

  def corruption_gc
    git_command('gc')
  end # corruption

  def status(pathspec = nil, options = '--untracked-files=all --ignored')
    pathspec_string = if pathspec.nil?
                        ''
                      else
                        ' -- ' + pathspec
                      end # if
    changes = git_command('status -z ' + options + pathspec_string).output
    ret = []
    unless changes.empty?
      changes.split("\u0000").map do |status_line|
        ret << FileStatus.new_from_status_line(status_line)
      end # map
    end # if
    ret
  end # status

  def something_to_commit?
    status.select(&:needs_commit?) != []
  end # something_to_commit

  def something_to_merge?
    status.select(&:needs_merge?) != []
  end # something_to_commit

  def testing_superset_of_passed
    git_command('shortlog testing..passed')
  end # testing_superset_of_passed

  def edited_superset_of_testing
    git_command('shortlog edited..testing')
  end # edited_superset_of_testing

  def force_change(content = README_start_text + Time.now.strftime('%Y-%m-%d %H:%M:%S.%L') + "\n")
    IO.write(@path + '/README', content) # timestamp makes file content unique
  end # force_change

  def revert_changes
    git_command('reset --hard')
  end # revert_changes

  def git_parse(command, pattern)
    output = git_command(command).output # .assert_post_conditions
    output.parse(pattern)
  end # git_parse

  module Constructors # such as alternative new methods
    include DefinitionalConstants
    def create_empty(path)
      Dir.mkdir(path)
      if File.exist?(path)
        ShellCommands.new([['cd', path], '&&', %w(git init)])
        new_repository = Repository.new(path)
      else
        raise "Repository.create_empty failed: File.exists?(#{path})=#{File.exist?(path)}"
      end # if
      new_repository
    end # create_empty

    def delete_existing(path)
      # @see http://www.ruby-doc.org/stdlib-1.9.2/libdoc/fileutils/rdoc/FileUtils.html#method-c-remove
      if File.exist?(path) && File.exist?(path + '/.git') # make sure its a repository
        FileUtils.remove_entry_secure(path, force = false)
      else
        raise path + ' does not exist as a git repository.'
       end # if
    end # delete_existing

    def delete_even_nonxisting(path, force = nil)
      # @see http://www.ruby-doc.org/stdlib-1.9.2/libdoc/fileutils/rdoc/FileUtils.html#method-c-remove
      if File.exist?(path)
        if File.exist?(path + '/.git') # make sure its a repository
          FileUtils.remove_entry_secure(path, force = false)
        elsif force
          FileUtils.remove_entry_secure(path, force = false)
        else
          raise path + ' is not a git repository.'
        end # if
       end # if
    end # delete_existing

    def replace_or_create(path)
      if File.exist?(path)
        delete_existing(path)
      end # if
      create_empty(path)
    end # replace_or_create

    def create_if_missing(path)
      if File.exist?(path)
        Repository.new(path)
      else
        create_empty(path)
      end # if
    end # create_if_missing

    def timestamped_repository_name?
      Repository_Unit.data_sources_directory? + Time.now.strftime('%Y-%m-%d_%H.%M.%S.%L')
    end # timestamped_repository_name?

    def create_test_repository(path = timestamped_repository_name?)
      replace_or_create(path)
      if File.exist?(path)
        new_repository = Repository.new(path)
        IO.write(path + '/README', README_start_text + "\n") # two consecutive slashes = one slash
        new_repository.git_command('add README')
        new_repository.git_command('commit -m "create_empty initial commit of README"')
        new_repository.git_command('branch passed')
      else
        raise "Repository.create_empty failed: File.exists?(#{path})=#{File.exist?(path)}"
      end # if
      new_repository
    end # create_test_repository
  end # Constructors
  extend Constructors

  module ReferenceObjects # example constant objects of the type (e.g. default_objects)
    include DefinitionalConstants
    This_code_repository = Repository.new(Root_directory)
  end # ReferenceObjects
  include ReferenceObjects
end # Repository
# assert_includes(Module.constants, :ShellCommands)
# assert_includes(Module.constants, :FilePattern)
# assert_includes(Module.constants, :Unit)
# assert_includes(Module.constants, :Capture)
# assert_includes(Module.constants, :Branch)
# assert_includes(Module.constants, :Repository)
# assert_includes(Repository.constants, :Constants)
# assert_includes(Repository.constants, :DefinitionalClassMethods)
