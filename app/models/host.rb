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
  attribute :nmap, Nmap, :default => ''
  attribute :name, String, :default => nil
module Constants
end # Constants
include Constants
#has_many :ports
#has_many :routers
module ClassMethods
include Constants
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
require_relative '../../test/assertions.rb'
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
