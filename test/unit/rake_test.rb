require 'test_helper'
require 'ftools'
require 'lib/tasks/testing.rb'
require 'active_support' # for singularize and pluralize
# executed in alphabetical orer? Longer names sort later.
# place in order from low to high level and easy pass to harder, so that first fail is likely the cause.
# move passing tests toward end
class RakeTest < ActiveSupport::TestCase
# mimic Rake fnction
def uptodate?(target,sources) 
	sources.each do |s|
		#~ system ("ls -l #{target}") {|ok, res| } # discard result if file doesn't exist
		#~ system "ls -l #{s}"
		if File.mtime(target)<File.mtime(s) then
			return false
		end #if
	end #each
	return true
end #def
def gitStatus(&process_status)
	return `git status --porcelain`.split("\n").each do |line| 
		status,file=line.split(" ")
		process_status.call(status,file)
	end #each
end #def
# [example_file, regexp, plural,test_type]
TABLE_FINDER_REGEXPS=[
{:example_file => 'app/models/global.rb', :regexp =>  %{^app/models/([a-zA-Z0-9_]+)[.]rb$}, :plural => false, :test_type => :both},
{:example_file => 'test/unit/global_test.rb', :regexp =>  %{^test/unit/([a-zA-Z0-9_]+)_test[.]rb$}, :plural => false, :test_type => :unit},
{:example_file => 'test/functional/accounts_controller_test.rb', :regexp =>  %{^test/functional/([a-zA-Z0-9_]+)_test[.]rb$}, :plural => true, :test_type => :controller},
{:example_file => 'log/unit/generic_table_test.log', :regexp =>  %{^log/unit/([a-zA-Z0-9_]+)_test[.]log$}, :plural => false, :test_type => :unit},
{:example_file => 'log/functional/accounts_controller_test.log', :regexp =>  %{^log/functional/([a-zA-Z0-9_]+)_controller_test[.]log$}, :plural => true, :test_type => :controller},
{:example_file => 'app/views/acquisition_stream_specs/_index_partial.html.erb', :regexp =>  %{^app/views/([a-z_]+)/[a-zA-Z0-9_]+[.]html[.]erb$}, :plural => true, :test_type => :controller}
]
def match_spec_from_file(file)
	TABLE_FINDER_REGEXPS.each do |match_specs|
		matchData=file.match(match_specs[:regexp])
		if matchData then
			match_specs[:matchData]=matchData # add match data found
			return match_specs
		end #if
	end #each
	return nil # if no match
end #def
def singular_table_from_file(file)
	match_spec=match_spec_from_file(file)
	if match_spec.nil? then
		return  nil
	else
		table_name=match_spec[:matchData][1]
		if match_spec[:plural] then
			return table_name.singularize
		else
			return table_name
		end #if
	end #if
end #def
# stage target and source files when all tests pass.
# stage model file and .yml files when BOTH unit and controller tests pass
def why_not_stage_helper(file,target,sources,test_type)
	if File.exists?(target) then
		#~ puts "Target #{target}  does exist." 
		if log_passed?(target) then
			system "git add #{target}"
			if  uptodate?(target,[file]) then
				if sources.include?(file) then
					system "git add #{file}"
					stage=true
				else
					puts "#{file} not a #{test_type} source."
				end #if
			else
				puts "#{file} not up to date." 
			end #if
			stage=true
		else
			stage=false
		end #if
		puts "#{file} not up to date."unless  uptodate?(target,[file]) 
		stage=false
	else
		puts "Target #{target} for file=#{file} does not exist."
		stage=false
	end #if

end #def
# stage target and source files when all tests pass.
# stage model file and .yml files when BOTH unit and controller tests pass
def why_not_stage(file,singular_table)
	match_spec=match_spec_from_file(file)
	if match_spec.nil? then
		singular_table=FILE_MOD_TIMES[FILE_MOD_TIMES.size/2][0] # pick average file, not too active, not too abandoned
		puts "#{file} don't know when to stage."
	else
		singular_table=singular_table_from_file(file)
		why_not_stage_helper(file,unit_target(singular_table),unit_sources(singular_table),:unit)  if match_spec[:test_type] != :controller
		why_not_stage_helper(file,controller_target(singular_table),controller_sources(singular_table),:controller)  if match_spec[:test_type] != :unit
	end #if
end #def
test "git status" do
	assert_equal('global',singular_table_from_file('app/models/global.rb'))
	assert_equal('global',singular_table_from_file('test/unit/global_test.rb'))
	TABLE_FINDER_REGEXPS.each do |match_specs|
		example_file=match_specs[:example_file]
		regexp=match_specs[:regexp]
		assert(File.exists?(example_file))
		if !example_file.match(regexp) then
			puts "#{example_file} not \n#{regexp.inspect}"
		else
			#~ puts "#{example_file} matches \n#{regexp.inspect}"
		end #if
	end #each_pair
	TABLE_FINDER_REGEXPS.each do |match_specs|
		example_file=match_specs[:example_file]
		regexp=match_specs[:regexp]
		assert(example_file.match(regexp))
	end #each_pair
	#~ TABLE_FINDER_REGEXPS.each do |match_specs|
		#~ example_file=match_specs[:example_file]
		#~ regexp=match_specs[:regexp]
		#~ assert_match(regexp,example_file)
	#~ end #each_pair
	TABLE_FINDER_REGEXPS.each do |match_specs|
		example_file=match_specs[:example_file]
		regexp=match_specs[:regexp]
		assert_not_empty(singular_table_from_file(example_file))
	end #each_pair
	#~ assert_match('app/views/acquisition_stream_specs/_index_partial.html.erb',TABLE_FINDER_REGEXPS['app/views/acquisition_stream_specs/_index_partial.html.erb'])
	assert_equal('acquisition_stream_specs','app/views/acquisition_stream_specs/_index_partial.html.erb'.match(TABLE_FINDER_REGEXPS[5][:regexp])[1])
	assert_equal('acquisition_stream_spec',singular_table_from_file('app/views/acquisition_stream_specs/_index_partial.html.erb'))
	assert_equal('global',singular_table_from_file('app/models/global.rb'))
	assert_not_nil(gitStatus{|status,file| puts "status=#{status}, file=#{file}"})
	file='app/views/acquisition_stream_specs/_index_partial.html.erb'
	assert_not_empty(singular_table_from_file(file))
	assert_nothing_raised{why_not_stage(file,singular_table_from_file(file)) }
	assert_nothing_raised{gitStatus{|status,file| why_not_stage(file,singular_table_from_file(file)) }}
	assert_equal(['global','unit'],table_type_from_source('test/unit/global_test.rb'))
#	assert_nothing_raised{why_not_stage_helper('app/views/acquisition_stream_specs/_index_partial.html.erb',target,sources,test_type)}
end #test
end #class