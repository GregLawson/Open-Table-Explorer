###########################################################################
#    Copyright (C) 2011-2012 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../../app/models/no_db.rb'
class Bug # < ActiveRecord::Base
  # has_many :test_runs
  # belongs_to :error_type

  # include Generic_Table
  # extend Generic_Table::ClassMethods
  def self.logical_primary_key
    [:created_at]
  end # def

  def initialize(test_type = nil, table = nil, error = nil)
    if test_type.nil?
      super(nil)
      return
    elsif test_type.instance_of?(Hash) || test_type.instance_of?(ActiveSupport::HashWithIndifferentAccess)
      puts "hash parameter=#{test_type}"
      super(test_type) # actually hash of attributes
    #		attributes=testType
    else
      puts "not hash, not empty: test_type.class=#{test_type.class}, test_type=#{test_type.inspect}, table=#{table}, error='#{error}'"
      super(nil)
      raise "not hash, not empty:  test_type.class=#{test_type.class}, test_type=#{test_type.inspect}, table=#{table}, error=#{error}" if error.nil?
      error.scan(/  ([0-9]+)[)] ([A-Za-z]+):\n(test_[a-z_]*)[(]([a-zA-Z]+)[)]:?\n(.*)$/m) do |_number, error_type, test, _klass, report|
        # ~ puts "number=#{number.inspect}"
        # ~ puts "error_type=#{error_type}"
        # ~ puts "test=#{test.inspect}"
        # ~ puts "klass=#{klass.inspect}"
        # ~ puts "report=#{report.inspect}"
        self.url = "rake testing:#{test_type}_test TABLE=#{table} TEST=#{test}"
        if error_type == 'Error'
          report.scan(/^([^\n]*)\n(.*)$/m) do |error, trace|
            self[:context] = trace.split("\n")
            puts "error='#{error.inspect}'"
            puts "trace='#{trace.inspect}'"
            puts "context=#{context.inspect}"
            open('db/bugs.sql', 'a') { |f| f.write("insert into bugs(url,error,context,created_at,updated_at) values('#{url}','#{error.tr("'", '`')}','#{context}','#{Time.now.rfc2822}','#{Time.now.rfc2822}');\n") }
          end # scan
        elsif error_type == 'Failure'
          report.scan(/^\s*[\[]([^\]]+)[\]]:\n(.*)$/m) do |trace, error|
            self[:context] = trace.split("\n")
            self[:error] = error.slice(0, 50)
            puts "error='#{error.inspect}'"
            puts "trace='#{trace.inspect}'"
            puts "context='#{context.inspect}'"
            open('db/bugs.sql', 'a') { |f| f.write("insert into bugs(url,error,context,created_at,updated_at) values('#{url}','#{error.tr("'", '`')}','#{context}','#{Time.now.rfc2822}','#{Time.now.rfc2822}');\n") }
          end # scan
        else
          puts "pre_match=#{s.pre_match}"
          puts "post_match=#{s.post_match}"
          puts "before #{s.rest}"
        end # if
      end # scan
    end # if
  end # parse_bug

  def short_context
    context.reverse[1..-1].collect { |t| t.slice(/`([a-zA-Z_]+)'/, 1) }.join(', ')
  end # def
end # class
