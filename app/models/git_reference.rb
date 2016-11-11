###########################################################################
#    Copyright (C) 2013-2016 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'rom' # how differs from rom-sql
require 'rom-sql' # conflicts with rom-csv and rom-rom
#require 'rom-relation' # conflicts with rom-csv and rom-rom
require 'rom-repository' # conflicts with rom-csv and rom-rom
require 'dry-types'
module Types
	include Dry::Types.module
end # Types
require_relative '../../app/models/shell_command.rb'
require_relative '../../app/models/parse.rb'
require_relative '../../test/assertions/repository_assertions.rb'
class GitReference
	module ClassMethods
		def head(repository)
			GitReference.new(name: :HEAD, repository: repository)
		end # head
	end # ClassMethods
	extend ClassMethods
  include Virtus.value_object

  values do
    attribute :name, Symbol
#		attribute :repository, Reposirory, :default => Repository:: # maybe repository independant for copying
#		attribute :sha1, String
  end # values

	def name
		@name	
	end # name
		
	def to_s
		name.to_s
	end # to_s
	
	def to_sym
		to_s.to_sym
	end # to_s
	
	def sha1
			run = repository.git_command('git show ' + to_s + ' --pretty=oneline  --no-abbrev-commit --no-patch')
	end # sha1
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
    attribute :age, Fixnum, default: 0
    attribute :timestamp, Time, default: Time.now
  end # values
  module ClassMethods
    include DefinitionalConstants
    def previous_changes(filename)
      reflog?(filename)
    end # previous_changes

    def reflog_to_constructor_hash(reflog_line)
      capture = reflog_line.capture?(BranchReference::Reflog_line_regexp)
      raise Exception.new(capture.inspect) unless capture.success?
      if capture.output[:ambiguous_branch].nil?
        { initialization_string: capture.output[:sha_hex].to_sym, age: 0, timestamp: capture.output[:timestamp] }
      else
        { initialization_string: capture.output[:ambiguous_branch].to_sym, age: capture.output[:age].uniq[0].to_i, timestamp: capture.output[:timestamp] }
      end # if
		end # reflog_to_constructor_hash
		
		def new_from_ref(reflog_line)
			new(reflog_to_constructor_hash(reflog_line))
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
    if @age.nil? || @age == 0
      name.to_s
    else
      name.to_s + '@{' + @age.to_s + '}'
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
				assert_match(BranchReference::Reflog_line_regexp, reflog_line)
        capture = reflog_line.capture?(BranchReference::Reflog_line_regexp)
        #	assert_equal(true, reflog_line.capture?(BranchReference::Ambiguous_ref_pattern).success?, capture.inspect)
        #	assert_equal(true, reflog_line.capture?(BranchReference::Unambiguous_ref_pattern).success?, capture.inspect)
        #	assert_equal(true, reflog_line.capture?(BranchReference::Ambiguous_ref_pattern.group * Regexp::Optional * Delimiter * Unambiguous_ref_pattern.group * Regexp::Optional).success?, capture.inspect)
        #	assert_equal(true, reflog_line.capture?(BranchReference::Ambiguous_ref_pattern.group * Regexp::Optional * Delimiter * Unambiguous_ref_pattern.group * Regexp::Optional * Delimiter * SHA_hex_7).success?, capture.inspect)
        #	assert_equal(true, reflog_line.capture?(BranchReference::Ambiguous_ref_pattern.group * Regexp::Optional * Delimiter * Unambiguous_ref_pattern.group * Regexp::Optional * Delimiter * SHA_hex_7 * Delimiter).success?, capture.inspect)
        #	assert_equal(true, reflog_line.capture?(BranchReference::Reflog_line_regexp).success?, capture.inspect)
        #	assert(capture.success?, capture.inspect)
        #	assert_match(BranchReference::Reflog_line_regexp, reflog_line)

				#	assert_match(Branch_name_regexp, capture.output[:ambiguous_branch])
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
        # ?	assert_equal([:ambiguous_branch, :age, :unambiguous_branch, :sha_hex, :timestamp], capture.output.keys, message)
        # ?	assert_equal([:ambiguous_branch, :age, :unambiguous_branch, :sha_hex, :timestamp], capture.regexp.names.map{|n| n.to_sym}, 'capture.regexp.names')
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
        assert_equal([:ambiguous_branch, :age, :unambiguous_branch, :sha_hex, :timestamp], BranchReference::Reflog_line_regexp.names.map(&:to_sym), 'capture.regexp.names')
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
