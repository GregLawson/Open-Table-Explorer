###########################################################################
#    Copyright (C) 2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'related_file.rb'
require_relative '../../app/models/shell_command.rb'
require_relative 'repository.rb'
class Release
module Constants
end #Constants
include Constants
module ClassMethods
end #ClassMethods
extend ClassMethods
def initialize(executable)
	raise "executable=#{executable.inspect} must be an String." if !executable.instance_of?(String)
	path2model_name=FilePattern.path2model_name?(executable)
	@related_files=RelatedFile.new(path2model_name, FilePattern.project_root_dir?(executable))
	message= "edit_files do not exist\n executable=#{executable.inspect}" 
	message+= "\n @related_files.edit_files=#{@related_files.edit_files.inspect}" 
	message+= "\n @related_files.missing_files=#{@related_files.missing_files.inspect}" 
#	raise message if  @related_files.edit_files.empty?
  @repository=Repository.new(@related_files.project_root_dir)
end #initialize
def unit_test
	begin
		deserving_branch=@repository.deserving_branch?(executable)
		@repository.recent_test.puts
		puts deserving_branch if $VERBOSE
		@repository.safely_visit_branch(deserving_branch) do
			@repository.validate_commit(@related_files.tested_files(executable))
		end #safely_visit_branch
		edit
	end until !@repository.something_to_commit? && @repository.recent_test.success? # infinite? interactive loop
end #unit_test
module Assertions
include Test::Unit::Assertions
module ClassMethods
include Test::Unit::Assertions
def assert_post_conditions
end #assert_post_conditions
end #ClassMethods
def assert_pre_conditions
end #assert_pre_conditions
def assert_post_conditions
end #assert_post_conditions
end #Assertions
include Assertions
extend Assertions::ClassMethods
#self.assert_pre_conditions
module Examples
include Constants
end #Examples
end #Release
