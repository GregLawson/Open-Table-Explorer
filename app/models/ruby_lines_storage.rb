###########################################################################
#    Copyright (C) 2014-2017 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../../app/models/parse.rb'
module RubyLinesStorage
  module DefinitionalConstants
    Eval_syntax_error_regexp = /\(eval\):/ * /[0-9]+/.capture(:line) * /: / * /.*/.capture(:message)
  end # DefinitionalConstants
  include DefinitionalConstants

  def self.read_error_context(path, file_contents, line_number = 2)
    context = "\n" + 'path = ' + path.to_s + "\n" + " in context: \n"
    context += file_contents.lines[(line_number - 2)..line_number].join
    context
  end # read_error_context

  def self.read(path)
    file_contents = IO.read(path)
    puts 'In order for RubyLinesStorage.read to succeed, file ' + path + ' must start with open curly brace.' + read_error_context(path, file_contents) if file_contents[0] != '{'
    eval(file_contents)
  rescue SyntaxError => exception_object
    exception_message = exception_object.message
    exception_hash = exception_message.parse(Eval_syntax_error_regexp)
    line_number = exception_hash[:line].to_i
    context = read_error_context(path, file_contents, line_number)
    #		puts exception_hash[:message] + context
    { context: context, file_contents: file_contents, exception_hash: exception_hash }
  end # read

  module Assertions
    module ClassMethods
    end # ClassMethods
  end # Assertions
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
