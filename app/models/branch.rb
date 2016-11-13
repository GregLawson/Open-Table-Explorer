###########################################################################
#    Copyright (C) 2013-2016 by Greg Lawson
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

class Branch < GitReference
	include Comparable
  # include Repository::Constants
  module DefinitionalConstants # constant parameters of the type (suggest all CAPS)
    # assert_global_name(:Repository)
    include BranchReference::DefinitionalConstants
    Branch_enhancement = [:passed, :tested, :edited].freeze # higher inex means more enhancements/bugs
    Extended_branches = { -4 => :'origin/master',
                          -3 => :work_flow,
                          -2 => :tax_form,
                          -1 => :master }.freeze
    More_mature = {
      master: :'origin/master',
      passed: :master,
      testing: :passed,
      edited: :tested
    }.freeze
    Subset_branch = {
      master: :tax_form,
      master: :work_flow, # duplicate key!
      work_flow: :unit,
      unit: :regexp
    }.freeze
		Interactive_branches = Branch_enhancement.map {|branch_symbol| (branch_symbol.to_s + '_interactive').to_sym}
		All_standard_branches = Branch_enhancement + Extended_branches.values + Interactive_branches
		Name_regexp = /[_a-z]+/.capture(:maturity) * /_interactive/.capture(:interactive).optional
    First_slot_index = Extended_branches.keys.min
    Last_slot_index = Branch_enhancement.size # how many is too slow?
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
      if branch_capture.success?
        branch_capture.output.map { |c| c[:branch].to_sym }
      else
        raise Exception.new('git branch parse failed = ' + branch_capture.inspect)
      end # if
    end # current_branch_name

    def branches?(repository = Repository::This_code_repository)
      branch_capture = branch_capture?(repository, '--list')
      if branch_capture.success?
        branch_capture.output.map do |c|
          Branch.new(repository: repository, name: c[:branch].to_sym)
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
      branches?(repository).map(&:name).uniq
    end # branch_names?

    def new_from_git_branch_line(git_branch_line)
    end # new_from_git_branch_line

    def revison_tag?(branch_index)
      '-r ' + Branch.branch_symbol?(branch_index).to_s
    end # revison_tag?
	
		def stash_wip(repository)
			command_string = 'git stash list'
			@cached_run = repository.git_command(command_string)
			regexp = /stash@{0}: WIP on / * Branch_name_regexp.capture(:parent_branch) * /: / *
				 SHA_hex_7.capture(:sha7) * / Merge branch '/ * Branch_name_regexp.capture(:merge_from) * /' into / * Branch_name_regexp.capture(:merge_into)
			capture = @cached_run.output.capture?(regexp)
			capture.output
		end # stash_wip
  end # ClassMethods
  extend ClassMethods
  include Virtus.value_object
  values do
    attribute :repository, Repository, default: Repository::This_code_repository
    attribute :remote_branch_name, Symbol, default: ->(branch, _attribute) { branch.find_origin }
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
	    self_index = Branch.branch_index?(self.name)
	    other_index = Branch.branch_index?(other.name)
			if self_index.nil? || other_index.nil?
				nil
			else
				comparison = -(self_index <=> other_index) # indices in reverse order of maturity
			end # if
		end # if
  end # compare

  def find_origin
    if Branch.remotes?(@repository).include?(name)
      ('origin/' + name.to_s).to_sym
    end # if
  end # find_origin
	
	def interactive?
			to_s.capture?(Name_regexp).output[:interactive]
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
	
  module Constants # constant objects of the type (e.g. default_objects)
		Master_branch = Branch.new(repository: Repository::Examples::This_code_repository, name: :master)
		Passed_branch = Branch.new(repository: Repository::Examples::This_code_repository, name: :passed)
    Tested_branch = Branch.new(repository: Repository::Examples::This_code_repository, name: :tested)
    Edited_branch = Branch.new(repository: Repository::Examples::This_code_repository, name: :edited)
    Stash_branch = Branch.new(repository: Repository::Examples::This_code_repository, name: :stash)
  end # Constants
  module Examples # usually constant objects of the type (easy to understand (perhaps impractical) examples for testing)
    include DefinitionalConstants
    include Constants
  end # Examples
end # Branch
