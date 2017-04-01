###########################################################################
#    Copyright (C) 2011-2016 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'rom' # how differs from rom-sql
require 'rom-sql' # conflicts with rom-csv and rom-rom
#require 'rom-relation' # conflicts with rom-csv and rom-rom
require 'rom-repository' # conflicts with rom-csv and rom-rom
require 'dry-types'
module Types
	include Dry::Types.module
end # Types

class Minimal4 < Dry::Types::Value
  module DefinitionalClassMethods
  end # DefinitionalClassMethods
  extend DefinitionalClassMethods

#    attribute :name, Types::Strict::Symbol | Types::Strict::String
#		attribute :data_regexp, Types::Coercible::String
#		attribute :ruby_conversion, Types::Strict::String.optional
module DefinitionalConstants # constant parameters of the type (suggest all CAPS)
end # DefinitionalConstants
include DefinitionalConstants
	
  module DefinitionalClassMethods
  end # DefinitionalClassMethods
  extend DefinitionalClassMethods
	
  module Constructors # such as alternative new methods
    include DefinitionalConstants
  end # Constructors
  extend Constructors
	
  module ReferenceObjects # constant objects of the type (e.g. default_objects)
    include DefinitionalConstants
  end # ReferenceObjects
  include ReferenceObjects
end #Minimal
