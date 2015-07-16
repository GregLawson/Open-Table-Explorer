###########################################################################
#    Copyright (C) 2013-2015 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'virtus'
#require_relative '../../app/models/no_db.rb'
class Minimal3
  include Virtus.value_object
  values do
# 	attribute :branch, Symbol
#	attribute :age, Fixnum, :default => 789
#	attribute :timestamp, Time, :default => Time.now
end # values
module Constants
end #Constants
include Constants
module ClassMethods
include Constants
end # ClassMethods
extend ClassMethods
#def initialize
#end # initialize
module Constants
end # Constants
include Constants
# attr_reader
end #Minimal
