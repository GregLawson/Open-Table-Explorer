###########################################################################
#    Copyright (C) 2014-2017 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../../app/models/parse.rb'

class Reconstruction
  module DefinitionalConstants
    Eval_syntax_error_regexp = /\(eval\):/ * /[0-9]+/.capture(:line) * /: / * /.*/.capture(:message)
		Read_fail_keys = [:exception_hash, :context_message, :ruby_lines_storage_string, :path]
  end # DefinitionalConstants
  include DefinitionalConstants

	attr_reader :constructor_code
	def initialize(constructor_code, context = nil)
		@constructor_code = constructor_code
		if context.nil?
			@context = {}
		else
			@context = context
		end # if
	end # initialize
	
  module Constructors # such as alternative new methods
    include DefinitionalConstants
  end # Constructors
  extend Constructors

	def reconstruction
		eval(@constructor_code)
  rescue SyntaxError => exception_object
    error_context = read_error_context(@constructor_code, exception_object)
    #		puts exception_hash[:message] + context
		error_context[:constructor_code] = @constructor_code
		error_context
	end # reconstruction
	
  def read_error_context(exception_object = nil)
    exception_message = exception_object.message
    exception_hash = exception_message.parse(Reconstruction::Eval_syntax_error_regexp)
		exception_hash[:exception_class] = exception_object.class.name
    line_number = exception_hash[:line].to_i
    context_message = @constructor_code.lines[(line_number - 2)..line_number].join
    { exception_hash: exception_hash, context_message: context_message }
  end # read_error_context

	def success?
		if (reconstruction.keys << :path).uniq == Read_fail_keys
			false
		else
			true
		end # if
	end # read_success?

  module Assertions
    def assert_post_conditions(message = '')
      message += "In assert_post_conditions, self=#{inspect}"
      self # return for command chaining
    end # assert_post_conditions
  end # Assertions
  include Assertions
end # Reconstruction

module RubyLinesStorage
  def self.read_error_context(ruby_lines_storage_string, exception_object = nil)
    exception_message = exception_object.message
    exception_hash = exception_message.parse(Reconstruction::Eval_syntax_error_regexp)
		exception_hash[:exception_class] = exception_object.class.name
    line_number = exception_hash[:line].to_i
    context_message = ruby_lines_storage_string.lines[(line_number - 2)..line_number].join
    { exception_hash: exception_hash, context_message: context_message }
  end # read_error_context

  def self.eval_rls(ruby_lines_storage_string)
    eval(ruby_lines_storage_string)
  rescue SyntaxError => exception_object
    error_context = read_error_context(ruby_lines_storage_string, exception_object)
    #		puts exception_hash[:message] + context
		error_context[:ruby_lines_storage_string] = ruby_lines_storage_string
		error_context
  end # eval_rls

	def self.read_success?(read_return)
		if (read_return.keys << :path).uniq == Reconstruction::Read_fail_keys
			false
		else
			true
		end # if
	end # read_success?

  def self.read(path)
    ruby_lines_storage_string = IO.read(path)
    raise 'In order for RubyLinesStorage.eval_rls to succeed, String ' + ruby_lines_storage_string + ' must start with open curly brace.' + read_error_context(path, ruby_lines_storage_string) if ruby_lines_storage_string[0] != '{'
    read_return = eval_rls(ruby_lines_storage_string)
		unless read_success?(read_return)
			read_return[:path] = path
		else
		end # if
		read_return
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
