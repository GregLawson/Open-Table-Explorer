###########################################################################
#    Copyright (C) 2014-2017 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../../app/models/parse.rb'

class Exception
		def Exception.rescued_value(rescued_exception_type, &block)
			if block_given?
				block.call
			else
				raise 'Exception.rescued_value must be passed a block.'
			end # if
		rescue rescued_exception_type => exception_object
			exception_object
		end # rescued_value
end # Exception

class SyntaxError < ScriptError
  module DefinitionalConstants
		Eval_error_regexp = /\(eval\):/ * /[0-9]+/.capture(:line)
		Syntax_error_regexp = /: / * /[ a-z]+/.capture(:class_words) * /, /
    Unexpected_regexp = /unexpected / * /[^,\Z]+/.capture(:unexpected)
		Context_regexp = Regexp[/\n/, /[^\n]*/.capture(:context), /[^\n]*/.capture(:position)]
    Expecting_regexp = /, expecting / * /[[:graph:]]+/.capture(:expecting)
		Eval_syntax_error_array = [ Eval_error_regexp, Syntax_error_regexp, 
			 Unexpected_regexp, Expecting_regexp.optional,  Context_regexp.optional]
		Eval_syntax_error_regexp = Regexp[Eval_syntax_error_array]
  end # DefinitionalConstants
  include DefinitionalConstants

  module Constructors # such as alternative new methods
		def rescued_eval(eval_source)
			Exception.rescued_value(SyntaxError) { eval(eval_source) }
		end # rescued_eval
  end # Constructors
  extend Constructors

  module ReferenceObjects # example constant objects of the type (e.g. default_objects)
    include DefinitionalConstants
		Expecting_right_paren_not_comma = {exception_class: SyntaxError, unexpected: ',', expecting: ')'}
		Expecting_right_brace_not_comma = {exception_class: SyntaxError, unexpected: ',', expecting: '}'}
		Unexpect_less_than = {exception_class: SyntaxError, unexpected: '<'}
		Expected_error_groups = [Expecting_right_paren_not_comma, Expecting_right_brace_not_comma, Unexpect_less_than]
  end # ReferenceObjects
  include ReferenceObjects

	def capture
    MatchCapture.new(string: message, regexp: Eval_syntax_error_array)
	end # capture
	
	def message_refinement
    capture.priority_refinements
	end # message_refinement

	def exception_hash
    message.parse(Eval_syntax_error_regexp)
	end # exception_hash
	
	def line_number
    exception_hash[:line].to_i
	end # line_number
	
	def unexpected
    exception_hash[:unexpected]
	end # unexpected
	
	def expecting
    exception_hash[:expecting]
	end # expecting
	
	def error_group
		{ exception_class: self.class, unexpected: unexpected, expecting: expecting }
	end # error_group
	
	def unseen?
		if success?
			false
		elsif Expected_error_groups.includes(error_group)
			false
		else
			true
		end # if
	end # unseen?
	
	def source_context(eval_source)
    @eval_source.lines[(line_number - 2)..line_number].join
	end # source_context
	
	def assert_syntax_OK(eval_source)
	end # assert_syntax_OK
end # SyntaxError

class RegexpError
		def RegexpError.rescued_regexp(regexp_source)
			Exception.rescued_value(RegexpError) { Regexp.new(regexp_source) }
		end # rescued_regexp
end # RegexpError

# save eval_source in object
class Eval
	def initialize(eval_source, context = nil)
		@eval_source = eval_source
		if context.nil?
			@context = {}
		else
			@context = context
		end # if
	end # initialize	

	def reconstruction
		SyntaxError.rescued_eval(@eval_source)
	end # reconstruction
	
  def context_message
    @eval_source.lines[(line_number - 2)..line_number].join
	end # context_message

	def success?
		if reconstruction.kind_of?(Exception)
			false
		else
			true
		end # if
	end # success?

	def ==(other)
		@eval_source == other.eval_source # no side effects, pure functions
	end # equals

	def <=>
		if self == other
			0
		elsif @eval_source > other.eval_source
			+1
		else
			-1
		end # if
	end # compare
end # Eval

class Reconstruction < Eval
  module DefinitionalConstants
		include SyntaxError::DefinitionalConstants
  end # DefinitionalConstants
  include DefinitionalConstants

	
  module Constructors # such as alternative new methods
    include DefinitionalConstants
		def read_all(directory_glob)
			Dir[directory_glob].map do |path|
			  RubyLinesStorage.read(path) 
			end # map
		end # read_all
		
		def errors_seen(directory_glob)
		    read_all(directory_glob).reject {|eval| eval.success? }
		end # errors_seen

		def unique_error_groups(directory_glob)
			errors_seen(directory_glob).map {|eval| eval.rescued_eval}.map(&:error_group).compact.uniq
		end # unique_error_groups
		
		def unexpected_errors(directory_glob)
			unique_error_groups(directory_glob).keys - [Expecting_right_paren_not_comma, Expecting_right_brace_not_comma, Unexpect_less_than ]
		end # unexpected_errors

		def select_error_group(directory_glob, error_group)
			read_all(directory_glob).select do |eval|
				eval.error_group == error_group
			end # select
		end # select_error_group
  end # Constructors
  extend Constructors

end # Reconstruction

module RubyLinesStorage

  def self.read(path)
    ruby_lines_storage_string = IO.read(path)
#!    raise 'In order for RubyLinesStorage.eval_rls to succeed, String ' + ruby_lines_storage_string + ' must start with open curly brace.'  if ruby_lines_storage_string[0] != '{'
    Eval.new(ruby_lines_storage_string, {path: path})
  end # read
	
  module Assertions
    module ClassMethods
			def assert_readable(path)
				read_return = RubyLinesStorage.read(path)
				assert_instance_of(Hash, read_return)
        message = read_return.ruby_lines_storage
				if RubyLinesStorage.read_success?(read_return)
					assert(RubyLinesStorage.read_success?(read_return), read_return.ruby_lines_storage)
					refute_includes(read_return.keys, :exception_hash, read_return.ruby_lines_storage)
				else
					refute(RubyLinesStorage.read_success?(read_return), read_return.ruby_lines_storage)
					assert_includes(read_return.keys, :exception_hash, read_return.ruby_lines_storage)
					assert_equal(Reconstruction::Read_fail_keys, read_return.keys)
					refute(RubyLinesStorage.read_success?(read_return), read_return.ruby_lines_storage)
					assert_includes(read_return.keys, :exception_hash, read_return.ruby_lines_storage)
					assert_equal(Reconstruction::Read_fail_keys, read_return.keys)
# [:exception_hash, :context_message, :ruby_lines_storage_string, :path]
          assert_instance_of(Hash, read_return[:exception_hash])
#!          puts read_return[:exception_hash].ruby_lines_storage
					context_message = read_return[:context_message]
					assert_instance_of(String, context_message, message)
					ruby_lines_storage_string = read_return[:ruby_lines_storage_string]
					assert_instance_of(String, ruby_lines_storage_string, message)
				end # if
			end # assert_read
    end # ClassMethods
  end # Assertions
	include Assertions
	extend Assertions::ClassMethods
end # RubyLinesStorage

class Array
  def ruby_lines_storage(line_length_limit = 50)
    elements = map(&:ruby_lines_storage) # map
    ret = ''
    line_length = 0
    elements.each do |element|
      if line_length + element.size + 2 < line_length_limit # if I add it
        ret += ', '
      else
        ret += ",\n"
        line_length = 0
      end # if
      ret += element
      line_length += element.size + 2 # delimiters
    end # while
    if elements.empty?
      '[]'
    else
      '[' + ret[2..-1] + ']' # remove pre-delimiter
    end # if
  end # ruby_lines_storage
end # Array

class Hash
  def ruby_lines_storage
    ret = []
    each_pair do |key, value|
      ret << key.ruby_lines_storage + ' => ' + value.ruby_lines_storage
    end # each_pair
    '{' + ret.join(",\n") + "\n" + "}\n"
  end # ruby_lines_storage
end # Hash

class NilClass
  def ruby_lines_storage
    'nil'
  end # ruby_lines_storage
end # NilClass

class Fixnum
  def ruby_lines_storage
    to_s
  end # ruby_lines_storage
end # Fixnum

class FalseClass
  def ruby_lines_storage
    'false'
  end # ruby_lines_storage
end # FalseClass

class TrueClass
  def ruby_lines_storage
    'true'
  end # ruby_lines_storage
end # TrueClass

class String
  def ruby_lines_storage
    string = to_s
    "'" + string.gsub("'", "\\\\'") + "'"
  end # ruby_lines_storage
end # String

class Regexp
  def ruby_lines_storage
    '/' + CharacterEscape.readably_escaped(self) + '/'
  end # ruby_lines_storage
end # Regexp

class MatchData
  def ruby_lines_storage
    self[0].inspect + '.match(' + '/' + CharacterEscape.readably_escaped(regexp) + '/' + ')' # .match(@regexp)
  end # ruby_lines_storage
end # MatchData

class Module
  def ruby_lines_storage
    name.to_s
  end # ruby_lines_storage
end # Module

class Symbol
  def ruby_lines_storage
    inspect
    #		':' + to_s
  end # ruby_lines_storage
end # Symbol

class Date
  def ruby_lines_storage
    'Date.new(' + year.to_s + ', ' + month.to_s + ', ' + day.to_s + ', ' + ')'
    #		strftime('%Y-%m-%d')
    #		':' + to_s
  end # ruby_lines_storage
end # Date

class DateTime
  def ruby_lines_storage
    'Time.new(' + year.to_s + ', ' + month.to_s + ', ' + day.to_s + ', ' + hour.to_s + ', ' + min.to_s + ', ' + (1_000_000_000 * sec + nsec).to_s + '/1000000000, "' + strftime('%:z') + '").to_datetime'
    #		strftime('%Y-%m-%d')
    #		':' + to_s
  end # ruby_lines_storage
end # DateTime

class Time
  def ruby_lines_storage
    'Time.new(' + year.to_s + ', ' + month.to_s + ', ' + day.to_s + ', ' + hour.to_s + ', ' + min.to_s + ', Rational(' + (1_000_000_000 * sec + nsec).to_s + ', 1000000000), "' + strftime('%:z') + '")'
    #		strftime('%Y-%m-%d %H:%M:%S.%L')
    #		':' + to_s
  end # ruby_lines_storage
end # Time

class Exception
  def ruby_lines_storage
    'e = Exception.new("' + message.to_s + '");e.set_backtrace(' + backtrace.ruby_lines_storage + ');e'
  end # ruby_lines_storage
end # Exception

class Object
  def ruby_lines_storage
    ret = self.class.name.to_s + '.new(' +
          (instance_variables - [:@allowed_writer_methods]).map do |iv_name|
            instance_variable_value = instance_variable_get(iv_name).ruby_lines_storage
            iv_name.to_s[1..-1] + ': ' + instance_variable_value
          end.join(",\n   ") # map
    ret + ")\n" # remove terminating linefeed and comma
  end # ruby_lines_storage
end # Object
