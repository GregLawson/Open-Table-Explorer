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
		system ("ls -l #{target}") {|ok, res| } # discard result if file doesn't exist
		system "ls -l #{s}"
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
TABLE_FINDER_REGEXPS={
'app/models/global.rb' => %{^app/models/([a-zA-Z0-9_]+)[.]rb$},
'test/unit/global_test.rb' => %{^test/unit/([a-zA-Z0-9_]+)_test[.]rb$},
'test/functional/accounts_controller_test.rb' => %{^test/functional/([a-zA-Z0-9_]+)_test[.]rb$},
'log/unit/generic_table_test.log' => %{^log/unit/([a-zA-Z0-9_]+)_test[.]log$},
'log/functional/accounts_controller_test.log' => %{^log/functional/([a-zA-Z0-9_]+)_controller_test[.]log$},
'app/views/acquisition_stream_specs/_index_partial.html.erb' => %{^app/views/([a-z_]+)/[a-zA-Z0-9_]+[.]html[.]erb$}
}
def table_from_file(file)
	TABLE_FINDER_REGEXPS.each_pair do |example_file,regexp|
		matchData=file.match(regexp)
		if matchData then
			return matchData[1].singularize
		end #if
	end #each
	return 'account'
end #def
# stage target and source files when all tests pass.
def why_not_stage(file,singular_table)
	puts "#{file} not a unit source."unless unit_sources(singular_table).include?(file)
	puts "#{file} not a controller source."unless controller_sources(singular_table).include?(file)
	target=unit_target(singular_table)
	puts "#{file} not up to date."unless  uptodate?(target,[file]) 
	puts "Target #{target}  does not exist."unless  File.exists?(target) 
	target=controller_target(singular_table)
	if File.exists?(target) then
		puts "Target #{target}  does exist."unless  File.exists?(target) 
		puts "#{file} not up to date."unless  uptodate?(target,[file]) 
		stage=false
	else
		puts "Target #{target}  does not exist."unless  File.exists?(target) 
	end #if
	return stage
end #def
test "git status" do
	assert_equal('global',table_from_file('app/models/global.rb'))
	assert_equal('global',table_from_file('test/unit/global_test.rb'))
	TABLE_FINDER_REGEXPS.each_pair do |example_file,regexp|
		assert(File.exists?(example_file))
		if !example_file.match(regexp) then
			puts "#{example_file} not \n#{regexp.inspect}"
		else
			#~ puts "#{example_file} matches \n#{regexp.inspect}"
		end #if
	end #each_pair
	TABLE_FINDER_REGEXPS.each_pair do |example_file,regexp|
		assert(example_file.match(regexp))
	end #each_pair
	#~ TABLE_FINDER_REGEXPS.each_pair do |example_file,regexp|
		#~ assert_match(regexp,example_file)
	#~ end #each_pair
	TABLE_FINDER_REGEXPS.each_pair do |example_file,regexp|
		assert_not_empty(table_from_file(example_file))
	end #each_pair
	#~ assert_match('app/views/acquisition_stream_specs/_index_partial.html.erb',TABLE_FINDER_REGEXPS['app/views/acquisition_stream_specs/_index_partial.html.erb'])
	assert_equal('acquisition_stream_specs','app/views/acquisition_stream_specs/_index_partial.html.erb'.match(TABLE_FINDER_REGEXPS['app/views/acquisition_stream_specs/_index_partial.html.erb'])[1])
	assert_equal('acquisition_stream_spec',table_from_file('app/views/acquisition_stream_specs/_index_partial.html.erb'))
	assert_equal('global',table_from_file('app/models/global.rb'))
	assert_not_nil(gitStatus{|status,file| puts "status=#{status}, file=#{file}"})
	file='app/views/acquisition_stream_specs/_index_partial.html.erb'
	assert_not_empty(table_from_file(file))
	assert_nothing_raised{why_not_stage(file,table_from_file(file)) }
	assert_nothing_raised{gitStatus{|status,file| why_not_stage(file,table_from_file(file)) }}
end #test
end #class