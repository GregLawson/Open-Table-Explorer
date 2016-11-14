###########################################################################
#    Copyright (C) 2013-2016 by Greg Lawson
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
require_relative '../../app/models/shell_command.rb'
require_relative '../../app/models/parse.rb'
require_relative '../../test/assertions/repository_assertions.rb'
class GitReference # base class for all git references (readable, maybe not writeable)
  module DefinitionalClassMethods # if reference by DefinitionalConstants or not referenced
		def head(repository)
			GitReference.new(name: :HEAD, repository: repository)
		end # head
  end # DefinitionalClassMethods
  extend DefinitionalClassMethods

	module DefinitionalConstants # constant parameters in definition of the type (suggest all CAPS)
	end # DefinitionalConstants
	include DefinitionalConstants
	
  include Virtus.value_object

  values do
    attribute :name, Symbol
    attribute :repository, Repository, default: Repository::This_code_repository
#		attribute :sha1, String
  end # values

	def name
		@name	
	end # name
		
	def to_s
		name.to_s
	end # to_s
	
	def to_sym
		to_s.to_sym
	end # to_s
	
	def sha1
			run = repository.git_command('git show ' + to_s + ' --pretty=oneline  --no-abbrev-commit --no-patch')
	end # sha1
  
  module ReferenceObjects # example constant objects of the type (e.g. default_objects)
    include DefinitionalConstants
		Head_at_start = GitReference.new(name: :HEAD, repository: Repository::This_code_repository)
  end # ReferenceObjects
  include ReferenceObjects
	end # GitReference
