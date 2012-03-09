###########################################################################
#    Copyright (C) 2011 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'test/unit'
require 'active_support' # for singularize and pluralize
require 'lib/tasks/testing.rb'
require 'app/models/global.rb'
require 'app/models/regexp_parser.rb'
require 'app/models/generic_table_html.rb'
require 'app/models/generic_table_association.rb'
require 'app/models/generic_grep.rb'
require 'app/models/column_group.rb'
require 'app/models/generic_table.rb'
require 'app/models/code_base.rb'
require 'app/models/test_run.rb'
class Test_Acquisition <Test::Unit::TestCase
require 'test_helpers.rb'
include Test_Helpers
include Global
def test_model_acquire_all
		assert_not_nil(model_class_name)
		assert_not_equal(advancedTime,previousTime)
		assert_equal(advancedTime,model.scheduled_time)
		assert_in_delta(advancedTime,previousTime+model.flooredSleepInterval,0.5,"model.scheduled_time=#{model.scheduled_time}, previousTime=#{previousTime}, model.interval=#{model.interval}")

		acquisitionData=testCall(model,:acquire)
		assert_instance_of(Array,acquisitionData)
		
end #def
def test_scheduler
	assert_not_nil(scheduleAll)
	schedule=scheduleAll.map{ |a| a.scheduled_time=Time.now;a}
	assert_not_nil(schedule)
	assert_not_nil(schedule)
	assert_not_nil(schedule.first)
	assert_not_nil(schedule.first.scheduled_time)
	assert_operator(schedule.first.scheduled_time,:<,Time.new)
	assert_operator(schedule.last.scheduled_time,:<,Time.new)
#	assert_operator(nextAcq.scheduled_time-Time.now,:>,0.0)
	assert_not_nil(nextAcq)
end #def
end #class