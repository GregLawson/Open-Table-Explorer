require 'test_helper'
require 'ftools'
require 'lib/tasks/testing.rb'
require 'active_support' # for singularize and pluralize
# executed in alphabetical orer? Longer names sort later.
# place in order from low to high level and easy pass to harder, so that first fail is likely the cause.
# move passing tests toward end
class RakeTest < ActiveSupport::TestCase
# mimic Rake function
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
	assert_include('app/views/acquisition_stream_specs/index.html.erb',controller_sources('acquisition_stream_spec'))
end #test
end #class