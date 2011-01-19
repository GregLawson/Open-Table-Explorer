###########################################################################
#    Copyright (C) 2010 by Greg Lawson                                      
#    <GregLawson@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'test/unit'
#require 'generic.rb'
require 'model.rb'
#require 'webBox.rb' # until sunnyweb box integrated
class Test_Generic <Test::Unit::TestCase
require 'test_helpers.rb'
def test_models
	Table_specs.model_classes.each do |m|
		modelRef=MODEL_REFS[m]
		assert_not_nil(modelRef)
		if modelRef.table_exists? then
 			explain_assert_respond_to(modelRef,:updates)
		else
			puts "Database table #{modelRef.table_name} does not exist.  Many methods will not work."
			puts "modelRef.table_name=#{modelRef.table_name}"
		end
	end #each
end
def test_model_acquire_and_parse
	Table_specs.model_classes.each do |m|
		table=Generic_Acquisitions.new(m)
		assert_not_nil(table)
		explain_assert_respond_to(table,:Column_Definitions)
		explain_assert_respond_to(table,:acquire)
		if table.file_caching.nil? || table.file_caching.empty? then
		else
			uri=URI.new(table.url)
			makedirs(uri.Host)
			if table.file_caching=='read' then
				open(uri.Host+uri.Path) do |file|
					acquisitionData=file.readline('')
				end
			elsif table.file_caching=='write' then
				acquisitionData=table.acquire
				open(uri.Host+uri.Path,'a') do |file|
					acquisitionData=table.acquire
					file.write(acquisitionData)
					file.puts
					file.puts # two newlines as record separator ?Windows?
				end
			else
			end #if
		end
		assert_not_nil(table.acquisitionData)
		assert(table.acquisitionData.size>0)
		explain_assert_respond_to(table,:parse)
		variableHashes=table.parse
		assert_instance_of(Array,variableHashes)
		variableHashes.each do |vhs|
			assert_instance_of(Array,vhs)
			vhs.each do |vh|
				assert_instance_of(Hash,vh)
			end #each
		end #each

		assert(variableHashes.size>0)
		table.updates(variableHashes)
		explain_assert_respond_to(table,:scaffold)

		end #each
end

def test_loops
	assert(Table_specs.model_classes.size>0,"Table_specs.model_classes has no rows.")
	assert_model('MULTIPLE_WEATHER')
	Table_specs.model_classes.each do |m|
		assert_model(m)
		assert(Generic_Acquisitions.all(:conditions =>{:model_class=>m}, :select => 'model_class,acquisition_interface,parse_interface', :group => 'model_class,acquisition_interface,parse_interface').size>0)
		assert(Generic_Acquisitions.acquisition_classes(m).size>0,"Generic_Acquisitions.acquisition_classes(#{m}) returns no data.")
		acqClasses=Generic_Acquisitions.acquisition_classes(m)
		acqClasses.each do |actr|
			Generic_Acquisitions.urls(actr).each do |urlTR|
				assert_instance_of(String,urlTR.url)
			end
			classDef=Acquisition_Classes.classDefinition(actr.model_class, actr.acquisition_interface, actr.parse_interface)
			assert_nothing_raised(classDef){eval(Acquisition_Classes.classDefinition(actr.model_class, actr.acquisition_interface, actr.parse_interface))}
			puts "classDef=#{classDef}" if $DEBUG
			eval(classDef)
			classRef=Acquisition_Classes.class_Reference(actr.model_class, actr.acquisition_interface, actr.parse_interface)
			puts "classRef=#{classRef}" if $DEBUG
			assert_nothing_raised(actr.inspect){classRef=Acquisition_Classes.class_Reference(actr.model_class, actr.acquisition_interface, actr.parse_interface)}
			explain_assert_respond_to(classRef,:acquire)
#debug			explain_assert_respond_to(classRef,:acquisitionUpdated?)
			assert(Generic_Acquisitions.urls(actr).size>0,"Generic_Acquisitions.urls(#{actr.inspect}) returns no data.")
			Generic_Acquisitions.urls(actr).each do |a|
				assert(classRef.acquire(a.url).length>0,"#{classRef.name}.acquire(\"#{a.url}\") returns no data.")
			end #each
			ac=Acquisition_Classes.new(m,actr.acquisition_interface,actr.parse_interface)
			assert(ac.URLS.size==ac.ParseTypeRecords.size)
			assert(ac.URLS.size>0)
			assert(ac.ParseTypeRecords.size>0)
			assert(ac.URLS==ac.ParseTypeRecords.keys)
			assert(Generic_Acquisitions.parseTypeRecords(ac).size>0,"Generic_Acquisitions.parseTypeRecords(ac).size<=0")
			acqs=ac.acquire
			assert(acqs.size>0,"#{classRef.name}.acquire returns no data.")
			assert(ac.URLS==ac.acquisitionData.keys)
			explain_assert_respond_to(ac,:parse)
			explain_assert_respond_to(ac.classRef,:parse)

			parses=ac.URLS.collect do |url|
				ac.ParseTypeRecords[url].collect do |p|
					if ac.classRef.acquisitionUpdated?(ac.acquisitionData[url]) then
					variableHash=ac.classRef.parse(ac.acquisitionData[url],p.tree_walk)
					end #if
				end # collect
			end # collect
			explain_assert_respond_to(classRef,:parse)
			explain_assert_respond_to(classRef,:streamEnd)
#			assert(ac.parse(acqs).size>0)

		end #each

	end
end #def
def test_generic_acquisitions
	Generic_Acquisitions.all.each  do |ga|
		explain_assert_respond_to(ga,:acquire)
		explain_assert_respond_to(ga,:parse)
		explain_assert_respond_to(ga,:acquisitionUpdated?)
	end #each
end #def
def test_generic_classes
	Table_specs.model_classes.each do |m|
		acqClasses=Generic_Acquisitions.acquisition_classes(m)
		acqClasses.each do |ac|
			acqs=ac.acquire
			assert(acqs.size>0)
 			variableHashes=ac.parse
			assert(variableHashes.size>0)
			variableHashes.each do |vh|
				assert_instance_of(Hash,vh,"In #{ac.inspect}")
			end #each

		end #each
	end #each
end #def
end #class