###########################################################################
#    Copyright (C) 2013-2016 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
# require_relative '../../app/models/no_db.rb'
require_relative '../../app/models/shell_command.rb'
require_relative '../../app/models/parse.rb'
require_relative '../../app/models/repository.rb'
class GitReference
  include Virtus.value_object

  values do
    attribute :name, Symbol
  end # values
end # GitReference

class BranchReference < GitReference
  module DefinitionalConstants # constant parameters of the type (suggest all CAPS)  (e.g. default values)
    include Repository::Constants
    Branch_name_regexp = /[-a-zA-Z0-9_\/]+/ # conventional syntax
    # Branch_name_regexp = /[-a-zA-Z0-9_]+/ # extended syntax

    Unambiguous_ref_age_pattern = /[0-9]+/.capture(:age)
    Ambiguous_ref_pattern = Branch_name_regexp.capture(:ambiguous_branch) * /@\{/ * Unambiguous_ref_age_pattern * /}/
    Unambiguous_ref_pattern = Branch_name_regexp.capture(:unambiguous_branch) * /@\{/ * Unambiguous_ref_age_pattern * /}/
    Delimiter = ','.freeze
    SHA_hex_7 = /[[:xdigit:]]{7}/.capture(:sha_hex)
    Week_day_regexp = /[MTWFS][a-z]{2}/
    Day_regexp = /[0-9]{1,2}/
    Month_regexp = /[ADFJMNOS][a-z]+/
    Year_regexp = /[0-9]{2,4}/
    Hour_regexp = /[0-9][0-9]/
    Minute_regexp = /[0-9][0-9]/
    Second_regexp = /[0-9][0-9]/
    AMPM_regexp = / ?([PApa][Mm])?/
    Date_regexp = Day_regexp * ' ' * Month_regexp * ' ' * Year_regexp
    Timezone_number_regexp = /[-+][0-1][0-9][03]0/
    Time_regexp = Hour_regexp * ':' * Minute_regexp * ':' * Second_regexp * ' ' * Timezone_number_regexp
    Timestamp_regexp = (Week_day_regexp * Delimiter * ' ' * Date_regexp * ' ' * Time_regexp).capture(:timestamp)
    # Timestamp_regexp = /([0-9]{1,4}/|[ADFJMNOS][a-z]+ )[0-9][0-9][, /][0-9]{2,4}( [0-9]+:[0-9.]+( ?[PApa][Mm])?)?/
    Reflog_line_regexp = Regexp::Start_string * Ambiguous_ref_pattern.group * Regexp::Optional * Delimiter *
                         Unambiguous_ref_pattern.group * Regexp::Optional * Delimiter * SHA_hex_7 * Delimiter * Timestamp_regexp
  end # DefinitionalConstants
  include DefinitionalConstants
  include Virtus.value_object

  values do
    attribute :age, Fixnum, default: 789
    attribute :timestamp, Time, default: Time.now
  end # values
  module ClassMethods
    include DefinitionalConstants
    def previous_changes(filename)
      reflog?(filename)
    end # previous_changes

    def new_from_ref(reflog_line)
      capture = reflog_line.capture?(BranchReference::Reflog_line_regexp)
      raise Exception.new(capture.inspect) unless capture.success?
      if capture.output?[:ambiguous_branch].nil?
        new(name: capture.output?[:sha_hex].to_sym, age: 0, timestamp: capture.output?[:timestamp])
      else
        new(name: capture.output?[:ambiguous_branch].to_sym, age: capture.output?[:age].to_i, timestamp: capture.output?[:timestamp])
      end # if
    end # new_from_ref

    def reflog_command_string(filename, _repository, range = 0..10)
      'reflog  --all --skip=' + range.first.to_s + ' --max-count=' + range.last.to_s + ' --pretty=format:%gd,%gD,%h,%aD -- ' + filename.to_s
    end # reflog_command_string

    def reflog_command_lines(filename, repository, range = 0..10)
      repository.git_command(reflog_command_string(filename, repository, range)).output.split("\n")
    end # reflog_command_lines

    def reflog?(filename, repository, range = 0..10)
      lines = reflog_command_lines(filename, repository, range)
      lines = lines[0..-2] if lines[-1..-1] == ''
      lines.map do |reflog_line|
        if reflog_line == ''
          nil
        else
          BranchReference.new_from_ref(reflog_line)
        end # if
      end # map
    end # reflog?

    def last_change?(filename, repository)
      reflog = reflog?(filename, repository)
      if reflog.empty?
        nil
      else
        reflog[0]
      end # if
    end # last_change?
  end # ClassMethods
  extend ClassMethods
  def to_s
    if @age.nil?
      @name.to_s
    else
      @name.to_s + '@{' + @age.to_s + '}'
    end # if
  end # to_s
  require_relative '../../app/models/assertions.rb'
  module Assertions
    module ClassMethods
      include DefinitionalConstants
      def assert_reflog_line(reflog_line, _message = '')
        assert_pre_conditions('in assert_reflog_line, assert_pre_conditions')
        message = 'In assert_reflog_line, matchData = ' + reflog_line.match(BranchReference::Reflog_line_regexp).inspect
        #	assert_match(BranchReference::Ambiguous_ref_pattern, reflog_line)
        #	assert_match(BranchReference::Unambiguous_ref_pattern, reflog_line)
        #	assert_match(BranchReference::Ambiguous_ref_pattern.group * Regexp::Optional * Delimiter * Unambiguous_ref_pattern.group * Regexp::Optional, reflog_line, message)
        #	assert_match(BranchReference::Ambiguous_ref_pattern.group * Regexp::Optional * Delimiter * Unambiguous_ref_pattern.group * Regexp::Optional * Delimiter * SHA_hex_7, reflog_line, message)
        capture = reflog_line.capture?(BranchReference::Reflog_line_regexp)
        #	assert_equal(true, reflog_line.capture?(BranchReference::Ambiguous_ref_pattern).success?, capture.inspect)
        #	assert_equal(true, reflog_line.capture?(BranchReference::Unambiguous_ref_pattern).success?, capture.inspect)
        #	assert_equal(true, reflog_line.capture?(BranchReference::Ambiguous_ref_pattern.group * Regexp::Optional * Delimiter * Unambiguous_ref_pattern.group * Regexp::Optional).success?, capture.inspect)
        #	assert_equal(true, reflog_line.capture?(BranchReference::Ambiguous_ref_pattern.group * Regexp::Optional * Delimiter * Unambiguous_ref_pattern.group * Regexp::Optional * Delimiter * SHA_hex_7).success?, capture.inspect)
        #	assert_equal(true, reflog_line.capture?(BranchReference::Ambiguous_ref_pattern.group * Regexp::Optional * Delimiter * Unambiguous_ref_pattern.group * Regexp::Optional * Delimiter * SHA_hex_7 * Delimiter).success?, capture.inspect)
        #	assert_equal(true, reflog_line.capture?(BranchReference::Reflog_line_regexp).success?, capture.inspect)
        #	assert(capture.success?, capture.inspect)
        #	assert_match(BranchReference::Reflog_line_regexp, reflog_line)
      end # reflog_line

      def assert_output(reflog_line, message = '')
        assert_reflog_line(reflog_line)
        capture = reflog_line.capture?(BranchReference::Reflog_line_regexp)
        message += "\ncapture? = " + capture.inspect
        message = capture.inspect
        #	assert(capture.success?, message)
        # ?	assert_instance_of(Hash, capture.output?, message)
        # ?	assert_equal([:ambiguous_branch, :age, :unambiguous_branch, :sha_hex, :timestamp], capture.output?.keys, message)
        # ?	assert_equal([:ambiguous_branch, :age, :unambiguous_branch, :sha_hex, :timestamp], capture.regexp.names.map{|n| n.to_sym}, 'capture.regexp.names')
        # ?	assert_equal(capture.length_hash_captures, capture.regexp.named_captures.values.flatten.size, message)
        capture.regexp.named_captures.each_pair do |_capture_name, index_array|
          # ?		assert_instance_of(String, capture_name, message)
          # ?		assert_instance_of(Array, index_array, message)
          # ?		assert_operator(1, :<=, index_array.size, capture_name)
          if index_array.size > 1
            # ?			refute_equal(capture.string, capture.output?[capture_name.to_sym])
          end # if
        end # each_pair
        message += "\noutput? = " + reflog_line.capture?(BranchReference::Reflog_line_regexp).output?.inspect
        if capture.output?[:ambiguous_branch].nil?
        else
          message += "\nExact match of age in " + capture.output?.inspect
          # ?		assert_match(Regexp::Start_string * BranchReference::Unambiguous_ref_age_pattern * Regexp::End_string, reflog_line.capture?(BranchReference::Reflog_line_regexp).output?[:age], message)
          # ?		assert_match(Regexp::Start_string * BranchReference::Unambiguous_ref_age_pattern * Regexp::End_string, capture.output?[:age], message)
        end # if
      end # assert_output

      def assert_pre_conditions(message = '')
        message += "In assert_pre_conditions, self=#{inspect}"
        self
      end # assert_pre_conditions

      def assert_post_conditions(_message = '')
        assert_equal([:ambiguous_branch, :age, :unambiguous_branch, :sha_hex, :timestamp], BranchReference::Reflog_line_regexp.names.map(&:to_sym), 'capture.regexp.names')
        self
      end # assert_post_conditions
    end # ClassMethods
    def assert_pre_conditions(message = '')
      message += "In assert_pre_conditions, self=#{inspect}"
      #	assert_match(Branch_name_regexp, capture.output?[:ambiguous_branch])
      # ?	assert_match(BranchReference::Unambiguous_ref_age_pattern, @age.to_s, message)
      # ?	assert_match(BranchReference::Unambiguous_ref_age_pattern, self.age.to_s, message)
      # ?	assert_match(Regexp::Start_string * BranchReference::Unambiguous_ref_age_pattern * Regexp::End_string, self.age.to_s, message)
      self
    end # assert_pre_conditions

    def assert_post_conditions(message = '')
      message += "In assert_post_conditions, self=#{inspect}"
      self
    end # assert_post_conditions
  end # Assertions
  include Assertions
  extend Assertions::ClassMethods
  # self.assert_pre_conditions
  module Examples
    include DefinitionalConstants
    Reflog_line = 'master@{123},refs/heads/master@{123},1234567,Sun, 21 Jun 2015 13:51:50 -0700'.freeze
    Reflog_capture = Reflog_line.capture?(BranchReference::Reflog_line_regexp)
    Reflog_run_executable = Repository::This_code_repository.git_command('reflog  --all --pretty=format:%gd,%gD,%h,%aD -- ' + $PROGRAM_NAME)
    Reflog_lines = Reflog_run_executable.output.split("\n")
    Reflog_reference = BranchReference.new_from_ref(Reflog_line)
    Last_change_line = Reflog_lines[0]
    First_change_line = Reflog_lines[-1]
    No_ref_line = ',,911dea1,Sun, 21 Jun 2015 13:51:50 -0700'.freeze
  end # Examples
end # BranchReference

class Branch < GitReference
  # include Repository::Constants
  module DefinitionalConstants # constant parameters of the type (suggest all CAPS)
    # assert_global_name(:Repository)
    include BranchReference::DefinitionalConstants
    Branch_enhancement = [:passed, :testing, :edited].freeze # higher inex means more enhancements/bugs
    Extended_branches = { -4 => :'origin/master',
                          -3 => :work_flow,
                          -2 => :tax_form,
                          -1 => :master }.freeze
    More_mature = {
      master: :'origin/master',
      passed: :master,
      testing: :passed,
      edited: :testing
    }.freeze
    Subset_branch = {
      master: :tax_form,
      master: :work_flow, # duplicate key!
      work_flow: :unit,
      unit: :regexp
    }.freeze
    First_slot_index = Extended_branches.keys.min
    Last_slot_index = Branch_enhancement.size + 10 # how many is too slow?
    Branch_name_alternative = [Branch_name_regexp.capture(:branch)].freeze
    Pattern = /[* ]/ * /[a-z0-9A-Z_-]+/.capture(:branch) * /\n/
    Git_branch_line = [/[* ]/, / /, Branch_name_regexp.capture(:branch)].freeze
    Git_branch_remote_line = [/[* ]/, / /, Branch_name_alternative].freeze
    Branch_regexp = /[* ]/ * / / * /[-a-z0-9A-Z_]+/.capture(:branch) * /\n/
    Branches_regexp = Branch_regexp.group * Regexp::Many
    Patterns = [Pattern, Branches_regexp,
                /[* ]/ * / / * /[-a-z0-9A-Z_]+/.capture(:branch),
                /^[* ] / * /[a-z0-9A-Z_-]+/.capture(:branch)
          ].freeze
  end # DefinitionalConstants
  include DefinitionalConstants
  module ClassMethods
    # include Repository::Constants
    include DefinitionalConstants
    def branch_symbol?(branch_index)
      case branch_index
      when nil then raise 'branch_index=' + branch_index.inspect
      when -4 then :'origin/master'
      when -3 then :work_flow
      when -2 then :tax_form
      when -1 then :master
      when 0..Branch::Branch_enhancement.size - 1 then Branch::Branch_enhancement[branch_index]
      when Branch::Branch_enhancement.size then :stash
      else
        ('stash~' + (branch_index - Branch::Branch_enhancement.size).to_s).to_sym
      end # case
    end # branch_symbol?

    def branch_index?(branch_name)
      branch_index = Branch::Branch_enhancement.index(branch_name.to_sym)
      if branch_index.nil?
        if branch_name.to_s[0, 5] == 'stash'
          stash_depth = branch_name.to_s[6, branch_name.size - 1].to_i
          branch_index = stash_depth + Branch::Branch_enhancement.size
        end # if
        Branch::Extended_branches.each_pair do |index, branch|
          branch_index = index if branch == branch_name.to_sym
        end # each_pair
      end # if
      branch_index
    end # branch_index?

    def merge_range(deserving_branch)
      deserving_index = Branch.branch_index?(deserving_branch)
      if deserving_index.nil?
        raise deserving_branch.inspect + ' not found in ' + Branch::Branch_enhancement.inspect + ' or ' + Extended_branches.inspect
      else
        deserving_index + 1..Branch::Branch_enhancement.size - 1
      end # if
    end # merge_range

    def branch_capture?(repository, branch_command = '--list')
      branch_run = repository.git_command('branch ' + branch_command)
      if branch_run.success?
        branch_output = branch_run.output
        branch_output.capture?(Branch_regexp, SplitCapture)
      else
        raise Exception.new('branch_run failed' + branch_run.inspect)
      end # if
    end # branch_capture?

    def current_branch_name?(repository)
      branch_capture = branch_capture?(repository, '--list')
      if branch_capture.success?
        branch_capture.output?.map { |c| c[:branch].to_sym }
      else
        raise Exception.new('git branch parse failed = ' + branch_capture.inspect)
      end # if
    end # current_branch_name

    def branches?(repository = Repository::This_code_repository)
      branch_capture = branch_capture?(repository, '--list')
      if branch_capture.success?
        branch_capture.output?.map do |c|
          Branch.new(repository: repository, name: c[:branch].to_sym)
        end # map
      else
        raise Exception.new('git branch parse failed = ' + branch_capture.inspect)
      end # if
    end # branches?

    def remotes?(repository)
      pattern = /  / * /[a-z0-9\/A-Z]+/.capture(:remote)
      repository.git_parse('branch --list --remote', pattern)
    end # remotes?

    def merged?(repository)
      pattern = /  / * /[a-z0-9\/A-Z]+/.capture(:merged)
      repository.git_parse('branch --list --merged', pattern)
    end # merged?

    def branch_names?(repository = Repository::This_code_repository)
      branches?(repository).map(&:name).uniq
    end # branch_names?

    def new_from_git_branch_line(git_branch_line)
    end # new_from_git_branch_line

    def revison_tag?(branch_index)
      '-r ' + Branch.branch_symbol?(branch_index).to_s
    end # revison_tag?
  end # ClassMethods
  extend ClassMethods
  include Virtus.value_object

  values do
    attribute :repository, Repository, default: Repository::This_code_repository
    attribute :remote_branch_name, Symbol, default: ->(branch, _attribute) { branch.find_origin }
  end # values
  # Allows Branch objects to be used in most contexts where a branch name Symbol is expected
  def to_s
    @name.to_s
  end # to_s

  def to_sym
    @name.to_sym
  end # to_s

  def <=>(other)
    Branch.branch_index?(name) <=> Branch.branch_index?(other.name)
  end # compare

  def find_origin
    if Branch.remotes?(@repository).include?(@repository.current_branch_name?)
      'origin/' + @name.to_s
    end # if
  end # find_origin
  module Constants # constant objects of the type (e.g. default_objects)
  end # Constants
  module Examples # usually constant objects of the type (easy to understand (perhaps impractical) examples for testing)
    include DefinitionalConstants
    include Constants
  end # Examples
end # Branch
