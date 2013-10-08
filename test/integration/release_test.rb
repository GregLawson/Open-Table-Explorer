###########################################################################
#    Copyright (C) 2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative '../../app/models/release.rb'
require_relative '../../app/models/repository.rb'
require_relative '../../app/models/file_pattern.rb'
class ReleaseTest < TestCase
include DefaultTests
include TE.model_class?::Examples
def test_work_flow_script
end #work_flow_script
def test_unit_test_all
	pattern=FilePattern.find_by_name(:test)
	glob=pattern.pathname_glob
	puts 'glob='+glob
	tests=Dir[glob]
	puts tests.inspect
	tests.all? do |test|
		puts test
		Repository::Examples::SELF_code_Repo.deserving_branch?(test)==:passed
		Repository::Examples::SELF_code_Repo.recent_test.puts
	end #each
end #test_unit_test_all
end #Release
