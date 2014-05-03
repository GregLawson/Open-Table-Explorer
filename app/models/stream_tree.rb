###########################################################################
#    Copyright (C) 2013-2014 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################

# An attempt at a universal data type?
# Or is it duck typing modules without inheritance?
# A Stream is a generalization of Array, Enumerable allowing infinite length part of which can be a Tree data store
# A tree is a generalization of Tables and Nested Arrays and Hashes 
# in context see http://rubydoc.info/gems/gratr/0.4.3/file/README
# simple construction would give a tree
# sharing nodes would give a directed acyclic graph
# loops might be possible since ruby objects are references and self references are possible
#require_relative '../../app/models/no_db.rb'
# make as many methods in common between Array and Hash
# [] is the obvious method in common
# each_index and each_pair seem synonyms
# map should be added analogously to Hash
class Array
def each_pair
end # each_pair
def values
end # values
def keys
end # keys
end # Array
class Hash
def each_index
end # each_index
def map
end # map
end # Hash
module Stream # see http://rgl.rubyforge.org/stream/classes/Stream.html
include Enumerable
end # Stream
module Graph # see http://rubydoc.info/gems/gratr/0.4.3/file/README
end # Graph
module Tree
include Graph
# delegate to Array, Enumable and Hash
end # Tree
module StreamTree
include Stream
include Tree
module ClassMethods
end #ClassMethods
extend ClassMethods
module Constants
end #Constants
include Constants
# attr_reader
def initialize
end #initialize
require_relative '../../test/assertions.rb'
module Assertions
include Test::Unit::Assertions
module ClassMethods
include Test::Unit::Assertions
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
end #Assertions
include Assertions
extend Assertions::ClassMethods
#self.assert_pre_conditions
module Examples
include Constants
end #Examples
end #StreamTree
