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
require_relative '../../app/models/work_flow.rb'
class Release <WorkFlow
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
def unit_test(executable=@related_files.model_test_pathname?)
	begin
		deserving_branch=@repository.deserving_branch?(executable)
		if @repository.recent_test.success? then
			break
		end #if
		@repository.recent_test.puts
		puts deserving_branch if $VERBOSE
		@repository.safely_visit_branch(deserving_branch) do |changes_branch|
			@repository.validate_commit(changes_branch, @related_files.tested_files(executable))
		end #safely_visit_branch
		edit
	end until !@repository.something_to_commit? 
end #unit_test
require_relative '../../test/assertions.rb';module Assertions

module ClassMethods

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
