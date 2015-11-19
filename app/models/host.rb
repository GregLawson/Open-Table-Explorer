###########################################################################
#    Copyright (C) 2011-2015 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../../app/models/no_db.rb'
require 'virtus'
class Host # < ActiveRecord::Base
include Virtus.model
  attribute :host_xml, Hash, :default => ''

  attribute :ip, String, :default => nil
  attribute :addrtype, String, :default => lambda { |host, attribute| host.host_xml["address"]["addr"]}
  attribute :otherPorts, Fixnum, :default => nil
  attribute :otherState, String, :default => nil
  attribute :mac, String, :default => nil # 
  attribute :nicVendor, String, :default => nil
  attribute :name, String, :default => nil
module Constants
end # Constants
include Constants
#has_many :ports
#has_many :routers
module ClassMethods
include Constants
def new_from_xml(host_parsed_xml)
	Host.new(host_xml: host_parsed_xml, ip:  host_parsed_xml["address"]["addr"], otherPorts: host_parsed_xml["ports"]["extraports"]["count"])
end # new_from_xml
def logical_primary_key
	return [:name]
end #logical_primary_key
def recordDetection(ip,timestamp=Time.new)
	host=find_or_initialize_by_ip(ip)
	host.last_detection=timestamp
	host.save
end
end # ClassMethods
extend ClassMethods
module Constants
end # Constants
include Constants
def save
	to_json
end # save
# attr_reader
#require_relative '../../app/models/assertions.rb'
module Assertions
module ClassMethods
def assert_pre_conditions(message='')
	message+="In assert_pre_conditions, self=#{inspect}"
end #assert_pre_conditions
def assert_post_conditions(message='')
	message+="In assert_post_conditions, self=#{inspect}"
end #assert_post_conditions
end #ClassMethods
def assert_pre_conditions(message='')
end #assert_pre_conditions
def assert_post_conditions(message='')
end #assert_post_conditions
end # Assertions
include Assertions
extend Assertions::ClassMethods
#self.assert_pre_conditions
module Examples
include Constants
end # Examples
end # Host
