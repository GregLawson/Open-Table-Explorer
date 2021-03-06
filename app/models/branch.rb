###########################################################################
#    Copyright (C) 2013-2017 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
# require_relative '../../app/models/no_db.rb'
require_relative '../../app/models/git_reference.rb'
require 'rgl/implicit'
require 'rgl/adjacency'
require 'rgl/dot'

module MaturityBranches
  # assert_global_name(:Repository)
  #    include BranchReference::DefinitionalConstants

  Branch_enhancement = [:passed, :tested, :edited].freeze # higher inex means more enhancements/bugs
  Extended_branches = { -4 => :'origin/master',
                        -3 => :work_flow,
                        -2 => :tax_form,
                        -1 => :master }.freeze
  More_mature = {
    master: :'origin/master',
    passed: :master,
    tested: :passed,
    edited: :tested
  }.freeze
  Superset_branch = {
    tax_form: :master,
    work_flow: :master,
    unit: :work_flow,
    regexp: :unit
  }.freeze
  # Regexp
  Name_regexp = (/[a-z0-9]+/.capture(:scope) * /\//).optional * /[_a-z0-9]+/.capture(:maturity) * (/\+/ * /[_a-z]+/).capture(:test_topic).optional # also matches SHA1!
  Ref_name_regexp = /[-a-zA-Z0-9_\/]+/ # ref/heads/master
  # Name_regexp = /[-a-zA-Z0-9_]+/ # extended syntax
  Branch_name_alternative = [Name_regexp.capture(:branch)].freeze
  Pattern = /[* ]/ * /[a-z0-9A-Z_-]+/.capture(:branch) * /\n/
  Git_branch_line = [/[* ]/, / /, Name_regexp.capture(:branch)].freeze
  Git_branch_remote_line = [/[* ]/, / /, Branch_name_alternative].freeze
  #    Branch_regexp = /[* ]/ * / / * /[-a-z0-9A-Z_]+/.capture(:branch) * /\n/
  Branch_regexp = Capture::Examples::Branch_current_regexp
  Branches_regexp = Branch_regexp.group * Regexp::Many
  Patterns = [Pattern, Branches_regexp,
              /[* ]/ * / / * /[-a-z0-9A-Z_]+/.capture(:branch),
              /^[* ] / * /[a-z0-9A-Z_-]+/.capture(:branch)
        ].freeze
end # MaturityBranches

class Branch < NamedCommit # can commit to
  include MaturityBranches
  include Comparable
  # include Repository::Constants
  module DefinitionalClassMethods # if reference by DefinitionalConstants or not referenced
  end # DefinitionalClassMethods
  extend DefinitionalClassMethods

  module DefinitionalConstants # constant parameters of the type (suggest all CAPS)
    include MaturityBranches
    Interactive_branches = Branch_enhancement.map { |branch_symbol| (branch_symbol.to_s + '+interactive').to_sym }
    All_standard_branches = Branch_enhancement + Extended_branches.values + Interactive_branches
    First_slot_index = Extended_branches.keys.min
    Last_slot_index = Branch_enhancement.size # how many is too slow?
  end # DefinitionalConstants
  include DefinitionalConstants

  module DefinitionalClassMethods # if reference DefinitionalConstants
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
        raise deserving_branch.inspect + ' not found in ' + Branch::Branch_enhancement.inspect + ' or ' + Extended_branches.values.inspect
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
      current_branch_output = if branch_capture.success?
                                branch_capture.output.select { |c| c[:current] == '*' }
                              else
                                raise Exception.new('git branch parse failed = ' + branch_capture.inspect)
      end # if
      if current_branch_output.empty?
        nil
      else
        current_branch_output[0][:branch].to_sym
      end # if
    end # current_branch_name

    def current_branch(repository)
      Branch.new(repository: repository, initialization_string: current_branch_name?(repository))
    end # current_branch

    def branches?(repository = Repository::This_code_repository)
      branch_capture = branch_capture?(repository, '--list')
      if branch_capture.success?
        branch_capture.output.map do |c|
          Branch.new(repository: repository, initialization_string: c[:branch].to_sym)
        end # map
      else
        raise Exception.new('git branch parse failed = ' + branch_capture.inspect)
      end # if
    end # branches?

    def remotes?(repository)
      pattern = /  / * /[a-z0-9\/A-Z]+/.capture(:remote)
      remote_run = repository.git_command('branch --list --remote')
      captures = remote_run.output.capture?(pattern, SplitCapture)
      captures.output.map do |remote_hash|
        remote_hash[:remote].to_sym
      end # map
    end # remotes?

    def merged?(repository)
      pattern = /  / * /[a-z0-9\/A-Z]+/.capture(:merged)
      repository.git_parse('branch --list --merged', pattern)
    end # merged?

    def branch_names?(repository = Repository::This_code_repository)
      branches?(repository).map(&:initialization_string).uniq
    end # branch_names?

    def new_from_git_branch_line(git_branch_line)
    end # new_from_git_branch_line

    def revison_tag?(branch_index)
      '-r ' + Branch.branch_symbol?(branch_index).to_s
    end # revison_tag?
  end # DefinitionalClassMethods
  extend DefinitionalClassMethods

  include Virtus.value_object
  values do
    attribute :name, Symbol
    #    attribute :remote_branch_name, Symbol, default: ->(branch, _attribute) { branch.find_origin }
  end # values
  # Allows Branch objects to be used in most contexts where a branch name Symbol is expected

  def to_s
    name.to_s
  end # to_s

  def to_sym
    name.to_sym
  end # to_s

  def <=>(other)
    if self == other
      0
    else
      self_index = Branch.branch_index?(@name)
      other_index = Branch.branch_index?(other.name)
      if self_index.nil? || other_index.nil?
        nil
      else
        comparison = -(self_index <=> other_index) # indices in reverse order of maturity
      end # if
    end # if
  end # compare

  def find_origin # could be more than one e.g. origin and github
    expected_remote_name = ('origin/' + name.to_s).to_sym
    if Branch.remotes?(@repository).include?(expected_remote_name)
      expected_remote_name
    else
      "Why is't name = " + name.inspect + ' included in ' + Branch.remotes?(@repository).inspect
    end # if
  end # find_origin

  def interactive?
    to_s.capture?(Name_regexp).output[:test_topic]
  end # interactive?

  def maturity
    to_s.capture?(Name_regexp).output[:maturity]
  end # maturity

  def succ
    index = Branch.branch_index?(to_sym)
    if index.nil? || index + 1 > Last_slot_index
      nil
    else
      index + 1
    end # if
  end # succ

  def less_mature
    ret = []
    if interactive?
      ret << maturity
      ret << Branch.new(repository: @repository, name: Branch.branch_symbol?(maturity.succ))
    end # if
    index = succ
    unless index.nil?
      ret << Branch.new(repository: @repository, name: Branch.branch_symbol?(index))
    end # unless
    ret
  end # less_mature

  module ReferenceObjects # example constant objects of the type (e.g. default_objects)
    include DefinitionalConstants
    Master_branch = Branch.new(repository: Repository::This_code_repository, initialization_string: :master)
    Passed_branch = Branch.new(repository: Repository::This_code_repository, initialization_string: :passed)
    Tested_branch = Branch.new(repository: Repository::This_code_repository, initialization_string: :tested)
    Edited_branch = Branch.new(repository: Repository::This_code_repository, initialization_string: :edited)
    Stash_branch = Branch.new(repository: Repository::This_code_repository, initialization_string: :stash)
  end # ReferenceObjects
  include ReferenceObjects

  module Examples # usually constant objects of the type (easy to understand (perhaps impractical) examples for testing)
    include DefinitionalConstants
    include ReferenceObjects
  end # Examples
end # Branch

class BranchReference < Commit
  include Branch::ReferenceObjects
  module DefinitionalClassMethods # if reference by DefinitionalConstants
    def reflog_command_string(filename, _repository, range = 0..10, options = '')
      max_count = range.last - range.first + 1 # inclusive
      'reflog  --all --skip=' + range.first.to_s + ' --max-count=' + max_count.to_s + ' --pretty=format:%gd,%gD,%h,%aD ' + options + '-- ' + filename.to_s
    end # reflog_command_string

    def reflog_command_lines(filename, repository, range = 0..10, options = '')
      repository.git_command(reflog_command_string(filename, repository, range, options)).output.split("\n")
    end # reflog_command_lines

    def reflog?(filename, repository, range = 0..10, _options = '')
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

    def previous_changes(filename)
      reflog?(filename)
    end # previous_changes

    def last_change?(filename, repository)
      reflog = reflog?(filename, repository)
      if reflog.empty?
        nil
      else
        reflog[0]
      end # if
    end # last_change?

    def lost_edit(filename, repository, _range = 0..10, lost_code)
      reflogs = reflog?(filename, repository, range = 0..10, options = '-S "' + lost_code.to_s + '"')
    end # lost_edit

  end # DefinitionalClassMethods
  extend DefinitionalClassMethods

  module DefinitionalConstants # constant parameters in definition of the type (suggest all CAPS)
    include Repository::DefinitionalConstants
    include Commit::DefinitionalConstants
    include Branch::DefinitionalConstants
    Unambiguous_ref_age_pattern = /[0-9]+/.capture(:age)
    Ambiguous_ref_pattern = Name_regexp * /@\{/ * Unambiguous_ref_age_pattern * /}/
    Refs_prefix_regexp = /refs\// * (/heads|remotes/.capture(:ref) * /\//).optional
    Unambiguous_ref_pattern = (Refs_prefix_regexp * Ambiguous_ref_pattern).optional
    Delimiter = ','.freeze
    Regexp_array = [Regexp::Start_string * Ambiguous_ref_pattern.optional, Delimiter,
                    Unambiguous_ref_pattern, Delimiter, SHA1_hex_short, Delimiter, Git_reflog_timestamp_regexp].freeze
    #    Reflog_line_regexp = Regexp::Start_string * Ambiguous_ref_pattern.group * Regexp::Optional * Delimiter *
    #                         Unambiguous_ref_pattern.group * Delimiter * SHA1_hex_short * Delimiter * Timestamp_regexp
    Reflog_line_regexp = Regexp[Regexp_array]
  end # DefinitionalConstants
  include DefinitionalConstants

  module DefinitionalClassMethods # if reference DefinitionalConstants
    include BranchReference::DefinitionalConstants
  end # DefinitionalClassMethods
  extend DefinitionalClassMethods

  include Virtus.value_object

  values do
    attribute :branch, Branch
    attribute :age, Fixnum, default: 0
    attribute :timestamp, Time, default: Time.now
  end # values

  module Constructors # such as alternative new methods
    include DefinitionalConstants
    def new_from_ref(reflog_line, repository = Repository::This_code_repository)
      capture = reflog_line.capture?(BranchReference::Reflog_line_regexp)
      exception = Exception.new(capture.inspect)
      raise exception unless capture.success?
      hash = capture.output
      raise exception unless hash[:maturity][0] == hash[:maturity][1]
      raise exception unless hash[:age][0] == hash[:age][1]
      time_string = hash[:weekday] + ', ' + hash[:day_of_month] + ' ' + hash[:month] + ' ' + hash[:year] + ' ' + hash[:hour] + ':' + hash[:minute] + ':' + hash[:second] + ' ' + hash[:timezone]
      timestamp = Time.rfc2822(time_string)
      initialization_string, age = if capture.output[:maturity] == [nil, nil]
        [ hash[:sha1_hex_short].to_sym,  0 ]
      else
        [ hash[:maturity].uniq[0], hash[:age].uniq[0].to_i ]
      end # if
			if age == 0
        Commit.new(initialization_string: initialization_string, repository: repository)
			else
				new(initialization_string: initialization_string, repository: repository, timestamp:  timestamp)
      end # if
   end # new_from_ref
  end # Constructors
  extend Constructors

  def to_s
    if @age.nil? || @age == 0
      branch.to_s
    else
      branch.to_s + '@{' + @age.to_s + '}'
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
        #	assert_match(BranchReference::Ambiguous_ref_pattern.group * Regexp::Optional * Delimiter * Unambiguous_ref_pattern.group * Regexp::Optional * Delimiter * SHA1_hex_7, reflog_line, message)

        capture = MatchCapture.new(string: reflog_line, regexp: Regexp_array)
        capture.assert_refinement(:exact)
        show_matches = capture.priority_refinements.inspect
        #        priority_match = ParsedCapture.priority_match([reflog_line], Regexp_array)
        #        refute_equal([], priority_match, show_matches.ruby_lines_storage)
        #        assert_match(BranchReference::Ambiguous_ref_pattern, reflog_line, show_matches)
        #        assert_match(BranchReference::Unambiguous_ref_pattern, reflog_line, show_matches)
        assert_match(BranchReference::Reflog_line_regexp, reflog_line, show_matches)
        capture = reflog_line.capture?(BranchReference::Reflog_line_regexp)
        #	assert_equal(true, reflog_line.capture?(BranchReference::Ambiguous_ref_pattern).success?, capture.inspect)
        #	assert_equal(true, reflog_line.capture?(BranchReference::Unambiguous_ref_pattern).success?, capture.inspect)
        #	assert_equal(true, reflog_line.capture?(BranchReference::Ambiguous_ref_pattern.group * Regexp::Optional * Delimiter * Unambiguous_ref_pattern.group * Regexp::Optional).success?, capture.inspect)
        #	assert_equal(true, reflog_line.capture?(BranchReference::Ambiguous_ref_pattern.group * Regexp::Optional * Delimiter * Unambiguous_ref_pattern.group * Regexp::Optional * Delimiter * SHA1_hex_short).success?, capture.inspect)
        #	assert_equal(true, reflog_line.capture?(BranchReference::Ambiguous_ref_pattern.group * Regexp::Optional * Delimiter * Unambiguous_ref_pattern.group * Regexp::Optional * Delimiter * SHA1_hex_short * Delimiter).success?, capture.inspect)
        #	assert_equal(true, reflog_line.capture?(BranchReference::Reflog_line_regexp).success?, capture.inspect)
        #	assert(capture.success?, capture.inspect)
        #	assert_match(BranchReference::Reflog_line_regexp, reflog_line)

        #	assert_match(Name_regexp, capture.output[:ambiguous_branch])
        # ?	assert_match(BranchReference::Unambiguous_ref_age_pattern, @age.to_s, message)
        # ?	assert_match(BranchReference::Unambiguous_ref_age_pattern, self.age.to_s, message)
        # ?	assert_match(Regexp::Start_string * BranchReference::Unambiguous_ref_age_pattern * Regexp::End_string, self.age.to_s, message)
      end # reflog_line

      def assert_output(reflog_line, message = '')
        assert_reflog_line(reflog_line)
        capture = reflog_line.capture?(BranchReference::Reflog_line_regexp)
        message += "\ncapture? = " + capture.inspect
        message = capture.inspect
        #	assert(capture.success?, message)
        # ?	assert_instance_of(Hash, capture.output, message)
        # ?	assert_equal([:ambiguous_branch, :age, :unambiguous_branch, :sha1_hex_short, :timestamp], capture.output.keys, message)
        # ?	assert_equal([:ambiguous_branch, :age, :unambiguous_branch, :sha1_hex_short, :timestamp], capture.regexp.names.map{|n| n.to_sym}, 'capture.regexp.names')
        # ?	assert_equal(capture.length_hash_captures, capture.regexp.named_captures.values.flatten.size, message)
        capture.regexp.named_captures.each_pair do |_capture_name, index_array|
          # ?		assert_instance_of(String, capture_name, message)
          # ?		assert_instance_of(Array, index_array, message)
          # ?		assert_operator(1, :<=, index_array.size, capture_name)
          if index_array.size > 1
            # ?			refute_equal(capture.string, capture.output[capture_name.to_sym])
          end # if
        end # each_pair
        message += "\noutput = " + reflog_line.capture?(BranchReference::Reflog_line_regexp).output.inspect
        if capture.output[:ambiguous_branch].nil?
        else
          message += "\nExact match of age in " + capture.output.inspect
          # ?		assert_match(Regexp::Start_string * BranchReference::Unambiguous_ref_age_pattern * Regexp::End_string, reflog_line.capture?(BranchReference::Reflog_line_regexp).output[:age], message)
          # ?		assert_match(Regexp::Start_string * BranchReference::Unambiguous_ref_age_pattern * Regexp::End_string, capture.output[:age], message)
        end # if
      end # assert_output

      def assert_pre_conditions(message = '')
        message += "In assert_pre_conditions, self=#{inspect}"
        self
      end # assert_pre_conditions

      def assert_post_conditions(_message = '')
        assert_equal([:ambiguous_branch, :age, :unambiguous_branch, :sha1_hex_short, :timestamp], BranchReference::Reflog_line_regexp.names.map(&:to_sym), 'capture.regexp.names')
        self
      end # assert_post_conditions
    end # ClassMethods
    def assert_pre_conditions(message = '')
      message += "In assert_pre_conditions, self=#{inspect}"
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
end # BranchReference
