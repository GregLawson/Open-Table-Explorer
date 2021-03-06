###########################################################################
#    Copyright (C) 2011-2012 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../../app/models/no_db.rb'
require_relative '../../app/models/generic_table.rb' # in test_helper?
#require_relative '../../app/models/stream_method.rb'
require_relative '../../app/models/stream_pattern.rb'
require_relative '../../app/models/stream_pattern_argument.rb'
require_relative '../../app/models/url.rb'
require_relative '../../app/models/stream_method_argument.rb' # in test_helper?
class StreamMethod < ActiveRecord::Base # like a method def
  include Generic_Table
  has_many :stream_method_calls
  has_many :stream_method_arguments
  belongs_to :stream_pattern
  has_many :urls
  def self.logical_primary_key
    [:name]
  end # logical_key

  # after_initialize :compile_code!
  # functions of ActiveRecord  instances
  def initialize(hash = nil)
    super(hash)
  end # initialize

  def default_method
    rhs = case input_streams.size
          when 0
            '123'
          when 1
            input_streams[0].gui_name
          else
            '[' + input_streams.map(&:gui_name).join(',') + ']'
    end # case
    case output_streams.size
    when 0
      'puts ' + rhs
    when 1
      gui_name(output_streams[0]) + '=' + rhs
    else
      output_streams.map(&:gui_name).join(',') + '=' + rhs
    end # case

    #	return lhs+'='+rhs
  end # default_method

  # Allow external setting of instance variables
  def map_io(code)
    input_streams.each do |stream|
      code = code.gsub(stream.gui_name, stream.instance_name_reference)
      #		code=code+":input(#{stream.gui_name}, #{instance_name_reference(stream)})"
    end # each
    output_streams.each do |stream|
      code = code.gsub(stream.gui_name, instance_name_reference(stream))
      #		code=code+":output(#{stream.gui_name}, #{instance_name_reference(stream)})"
    end # each
    code
  end # map_io

  # create a instance (singleton) method with the supplied code.
  # the methods have no arguments and communicate through instance variables.
  def eval_method(name, code)
    if code.nil? || code.empty?
      rows = 0
      cols = 0
    else
      code_lines = code.split("\n")
      rows = code_lines.size
      cols = code_lines.map(&:length).max
    end # if

    instance_eval("def #{name}_rows\n#{rows}\nend\n")
    instance_eval("def #{name}_cols\n#{cols}\nend\n")
    method_def = "def #{name}_method\n#{map_io(code)}\nend\n"
    return instance_eval(method_def)
  rescue SyntaxError => exception_raised
    errors.add(name, 'SyntaxError: ' + exception_raised.inspect, options = {})
    return nil
    # ~ else
    # ~ self[:errorz]=self[:errorz].add(name, "Not subclass of SyntaxError: " + "couldn't compile string #{method_def} in context of a ruby_class object.")
  end # eval_method
  @@Default_Return_Code = ''
  acquireBody = "rescue StandardError => exception_raised\n"
  acquireBody += "errors.add(:acquisition,'Error: ' + exception_raised.inspect + 'could not get data from '+uri.inspect)"
  @@Default_Rescue_Code = acquireBody
  def compile_code!
    errors.clear # since code has presumably changed, old errors are irrelevant
    if library.nil?
      eval_method('interface_code', interface_code)
    else
      eval_method('interface_code', "require '#{library}'\n#{interface_code}")
    end # if

    if return_code.nil?
      eval_method('return_code', @@Default_Return_Code)
    else
      eval_method('return_code', return_code)
    end # if
    if rescue_code.nil?
      eval_method('rescue_code', @@Default_Rescue_Code)
    else
      eval_method('rescue_code', "rescue #{rescue_code}\n")
    end
  end # compile_code

  # syntax errors aggregated here
  # errors in general see http://api.rubyonrails.org/classes/ActiveModel/Errors.html
  def syntax_errors?
    errors[:interface_code] || errors[:return_code] || errors[:rescue_code]
  end # syntax_error

  def short_error_message
    error_message = syntax_error?
    if error_message.nil?
      return nil
    else
      return error_message.sub(/^\(eval\):\d+:in `syntax_error': compile error/, '').gsub(/\(eval\):\d+: syntax error, /, '').gsub(/\(eval\):\d+: /, '')
    end # if
  end # def

  def input_streams
    if stream_pattern.nil?
      return [] # pattern undefined
    else
      stream_pattern_arguments = stream_pattern.stream_pattern_arguments
      stream_inputs = stream_pattern_arguments.select { |a| a.direction == 'Input' }
      #		return stream_inputs.map{|a| a.name.downcase}
    end # if
  end # input_streams

  def output_streams
    if stream_pattern.nil?
      return [] # pattern undefined
    else
      stream_pattern_arguments = stream_pattern.stream_pattern_arguments
      stream_outputs = stream_pattern_arguments.select { |a| a.direction == 'Output' }
      #		return stream_outputs.map{|a| a.name.downcase}
    end # if
  end # output_streams

  def fire!
    errors.clear
    interface_code_method
    return_code_method
  rescue StandardError => exception_raised
    errors.add(:interface_code, exception_raised.inspect)
    rescue_code_method
  else
    errors.add(:interface_code, 'Not subclass of StandardError: ' + "couldn't acquire data from #{url}")
  ensure
    output_streams.each do |name|
      if self[name.to_sym].nil?
        errors.add(name, 'is empty.')
        if errors.empty?
          errors.add(:errors, 'was not set.')
        end # if
      else
        if errors.empty?
          errors.add(:errors, 'was not set.')
        else
          puts "errors=#{errors.inspect},output name=#{name.inspect}"
        end # if
      end #
    end # each
    return self
  end # fire
end # StreamMethod
