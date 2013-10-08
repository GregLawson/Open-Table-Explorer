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
	Repository::Examples::SELF_code_Repo.git_command('checkout passed')
	pattern=FilePattern.find_by_name(:test)
	glob=pattern.pathname_glob
	puts 'glob='+glob
	tests=Dir[glob]
	puts tests.inspect
	tests.each do |test|
		Release.new(test).unit_test
	end #each
end #test_unit_test_all
end #Release
