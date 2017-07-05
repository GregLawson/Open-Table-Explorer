###########################################################################
#    Copyright (C) 2011-2017 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../../app/models/shell_command.rb'
require_relative '../../app/models/parse.rb'
require_relative '../../app/models/uri.rb'
require_relative '../../app/models/generic_type.rb'
require_relative '../../app/models/cache.rb'
require 'open-uri'
class Acquisition # < Dry::Types::Value
  include Cache

  module DefinitionalClassMethods # if reference by DefinitionalConstants or not referenced
    def refine(acquisition_parameters, regexp, capture_class = MatchCapture)
      if block_given?
        refine(yield(acquisition_parameters), regexp, capture_class)
      else
        capture = capture_class.new(string: acquisition_parameters, regexp: regexp)
        refinement = capture.priority_refinements
      end # if
    end # refine

    def to_hash(acquisition_string, generic_type)
      acquisition_string.capture?(generic_type.to_regexp).output
    end # to_hash

    def open(acquisition_parameters)
      uri_parse = UriParse.new(initialization_string: acquisition_parameters)
      if uri_parse.uri.respond_to?(:open)
        begin
          Kernel.open(uri_parse.uri)
        rescue StandardError => exception_object
          { acquisition_parameters: acquisition_parameters, exception_object: exception_object, uri_parse: uri_parse, backtrace_locations: exception_object.backtrace_locations }
        end # begin / rescue
      end # if
    rescue StandardError => exception_object
      { acquisition_parameters: acquisition_parameters, exception_object: exception_object, uri_parse: uri_parse, backtrace_locations: exception_object.backtrace_locations }
    end # open

    def state(acquisition_parameters, generic_type)
      acquisition_open = Acquisition.open(acquisition_parameters)
      if acquisition_open.instance_of?(Hash)
        { acquisition_open: acquisition_open }
      else
        acquisition_string = acquisition_open.read
        capture = acquisition_string.capture?(generic_type)
        { acquisition_open: acquisition_open, acquisition_string: acquisition_string, capture: capture }
      end # if
    end # state
  end # DefinitionalClassMethods
  extend DefinitionalClassMethods

  module DefinitionalConstants # constant parameters in definition of the type (suggest all CAPS)
    Open_uri_open = ->(acquisition_parameters) { open(acquisition_parameters) }
    No_open = ->(acquisition_parameters) { acquisition_parameters }
    Open_uri_acquisition = ->(acquisition_parameters) { open(acquisition_parameters) }
    Shell_acquisition = ->(acquisition_parameters) { ShellCommands.new(acquisition_parameters) }
    String_acquisition = ->(acquisition_parameters) { acquisition_parameters }
    Git_acquisition = ->(acquisition_parameters) { acquisition_parameters[:repository].git_command(acquisition_parameters[:git_command]) }
  end # DefinitionalConstants
  include DefinitionalConstants

  include Virtus.value_object
  values do
    attribute :acquisition_parameters, Object
    attribute :generic_type, Regexp
#!    attribute :open_lambda, Proc
    attribute :acquisition_lambda, Proc
    # !    attribute :cached_acquisition_state, Object # caching because potentially slow
    # !		attribute :cached_capture, RawCapture # caching for debugging
  end # values

  def uri_parse
    UriParse.new(initialization_string: @acquisition_parameters)
  end # uri_parse

  def uri
    uri_parse.uri
  end # uri_parse

  def acquire!
    @cached_acquisition_state = Acquisition.state(@acquisition_parameters, @generic_type)
    if @cached_acquisition_state.keys.include?(:acquisition_string)
      @cached_acquisition_state[:acquisition_string]
    else
      @cached_acquisition_state
    end # if
  end # acquire!

  def acquisition_state
    cache do ||
      if @cached_acquisition_state.keys.include?(:acquisition_string)
        Acquisition.state(@acquisition_parameters, @generic_type)[:acquisition_string]
      else
        Acquisition.state(@acquisition_parameters, @generic_type)
      end # if
    end # cache
  end # acquisition_state

  def refine(capture_class = MatchCapture, &block)
    Acquisition.refine(@acquisition_parameters, @generic_type, capture_class, block)
  end # refine

  def capture
    cache(:capture) { || acquisition_state[:acquisition_string].capture?(@generic_type) }
  end # capture

  def to_hash
    if @cached_capture.nil?
      @cached_capture = @cached_acquisition_state[:acquisition_string].capture?(@generic_type)
      @cached_capture.output
    else
      @cached_capture.output
    end # if
  end # to_hash

  def acquisitionDuplicated?(acquisitionData = self[:acquisition_data])
    @previousAcq == acquisitionData
  end # acquisitionDuplicated?

  def acquisitionUpdated?(acquisitionData = self[:acquisition_data])
    acquisition_updated = if	acquisitionData.nil? || acquisitionData.empty?
                            false
                          elsif @previousAcq.nil? || @previousAcq.empty?
                            true
                          else
                            @previousAcq != acquisitionData
                          end
    self[:acquisition_updated] = acquisition_updated
    acquisition_updated
  end # acquisitionUpdated?

  def state
    Acquisition.state(@acquisition_parameters, @generic_type)
  end # state

  def display
    ret = 'display: '
    if error
      ret = '<EM>' + error + '</EM>'
      if acquisition_data
        ret += '<P>' + acquisition_data + '</P>'
      end # if
    else
      if acquisition_data
        ret = '<P>' + acquisition_data.truncate(200) + '</P>'
      else
        ret = '<EM>There are unexpectedly neither acquisition data nor any errors.</EM>'
      end # if
    end # if
    ret
  end # display

  def assert_refine(acquisition_parameters, regexp, capture_class = MatchCapture)
    capture = capture_class.new(string: acquisition_parameters, regexp: regexp)
    capture.assert_refinement(:exact)
    refinement = capture.priority_refinements
    end # refine
end # Acquisition
