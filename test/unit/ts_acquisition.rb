###########################################################################
#    Copyright (C) 2010 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'test/unit'
#require 'generic.rb'
require 'global.rb'
require 'model.rb'
require 'ga.rb'
require 'acquire.rb'
def gaTest(model)
	model_class_name=model.model_class_name
	assert_instance_of(Table_spec,model)
	assert_instance_of(String,model_class_name)
	explain_assert_respond_to(model,:acquire)
	explain_assert_respond_to(model,:acquisitionsUpdated?)
	acquisitionData=model.acquire
	assert_instance_of(Array,acquisitionData)
end #def

class Test_Acquisition <Test::Unit::TestCase
require 'test_helpers.rb'
include Test_Helpers
include Global
#~ def test_ac_acquire
	#~ typeRecord=Generic_Acquisitions.typeRecords('huell_schedule')[0]
	#~ Global::log.debug("typeRecord.inspect=#{typeRecord.inspect}")
	#~ dataToParse=HTTP_Acquisition.acquire(typeRecord.url)
#~ end #def
def test_new_model
	defaultAttributes={:model_class_name => 'nmap',
		:min_seconds => 3600,
		 :max_seconds => 24*3600,
		 :scheduled_time => Time.now,
		 :merge => 'table',
		 :file_caching => 'DB'}
	command='nmap 192.168.3.1-254'
	stream_attributes={:acquisition_interface =>'Shell_Acquisition',:url =>  command}
	network=Table_spec.find_by_model_class_name(defaultAttributes[:model_class_name])
	if network then
		network.update_attributes(defaultAttributes)
		stream=network.acquisition_stream_specs.all(:conditions =>stream_attributes)
		if !stream then
			network.acquisition_stream_specs.create(stream_attributes)
			network.acquisition_stream_specs.save
		end
	else
		network=Table_spec.new(defaultAttributes)
		stream=network.acquisition_stream_specs.all(:conditions =>stream_attributes)
		if !stream then
			network.acquisition_stream_specs.create(stream_attributes)
		end
	end #if
#	testAnswer(Shell_Acquisition.new,:acquire,[command,"cat\n"],command)
#	 testAnswer(network,:acquire,[[command,"cat\n"]])
end #def
def test_model_acquire_all
	Table_spec.all.each do |model|
		gaTest(model)
		model_class_name=model.model_class_name
		assert_not_nil(model_class_name)
#		typeRecord=Generic_Acquisitions.typeRecords(model_class_name)
		
#		tableType=MODEL_REFS[model_class_name]
#		table=tableType.new(model_class_name)
		testCall(model,:flooredSleepInterval)
		previousTime=model.scheduled_time
#		puts "previousTime=#{previousTime}"
		testCall(model,:updateSleepInterval)
#		advancedTime=testCall(model,:advanceScheduleTime)
		advancedTime=testCall(model,:advanceScheduleTime,model.flooredSleepInterval)
		assert_not_equal(advancedTime,previousTime)
		assert_equal(advancedTime,model.scheduled_time)
		assert_in_delta(advancedTime,previousTime+model.flooredSleepInterval,0.5,"model.scheduled_time=#{model.scheduled_time}, previousTime=#{previousTime}, model.interval=#{model.interval}")

		acquisitionData=testCall(model,:acquire)
		assert_instance_of(Array,acquisitionData)
		
		acquisitionData.each  do |aq|
#debug				assert_kind_of(Acquitition,aq)
				aq.save
		end
	end
end #def
def test_scheduler
	scheduleAll=Table_spec.all
	assert_not_nil(scheduleAll)
	schedule=scheduleAll.map{ |a| a.scheduled_time=Time.now;a}
	assert_not_nil(schedule)
	assert_not_nil(schedule)
	assert_not_nil(schedule.first)
	assert_not_nil(schedule.first.scheduled_time)
	assert_operator(schedule.first.scheduled_time,:<,Time.new)
	assert_operator(schedule.last.scheduled_time,:<,Time.new)
	schedule.each do |model|
		assert_not_nil(model.min_seconds)
		assert_not_nil(model.scheduled_time)
		assert_operator(model.scheduled_time,:<,Time.new)
		previousTime=model.scheduled_time
		advancedTime=testCall(model,:advanceScheduleTime,model.flooredSleepInterval)
#		advancedTime=model.advanceScheduleTime
		assert_equal(advancedTime,model.scheduled_time)
		assert_operator(advancedTime,:>,previousTime)
		assert_operator(model.scheduled_time,:>,previousTime)
		model.updateSleepInterval(true)
		assert_operator(model.shortest_update,:>,0.0)
		model.updateSleepInterval(false)
		assert_operator(model.longest_no_update,:>,0.0)
		model.scheduled_time=Time.now # keep tests from  long delays
		assert_operator(model.scheduled_time,:<,Time.now)
		assert_operator(model.scheduled_time-Time.now,:>,-1.0)
		assert_operator(model.scheduled_time-Time.now,:<,5.0)
	end # each
	schedule.each do |model|
		assert_operator(model.scheduled_time,:<,Time.now)
		assert_operator(model.scheduled_time-Time.now,:<,5.0)
	end # each
	nextAcq=Table_spec.nextAcquisition(true)
#	assert_operator(nextAcq.scheduled_time-Time.now,:>,0.0)
#debug	assert_operator(nextAcq.scheduled_time-Time.now,:<,5.0,nextAcq.inspect)
	assert_not_nil(nextAcq)
#slow	assert_not_nil(Table_spec.nextAcquisition(false))
end #def
end #class