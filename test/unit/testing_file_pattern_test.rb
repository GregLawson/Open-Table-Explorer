require 'test_helper'
require 'lib/tasks/testing_file_patterns.rb'
# executed in alphabetical orer? Longer names sort later.
# place in order from low to high level and easy pass to harder, so that first fail is likely the cause.
# move passing tests toward end
require 'test/test_helper_test_tables.rb'
class TestingFilePatternsTest < ActiveSupport::TestCase
require 'lib/tasks/testing.rb'
test 'match_spec_from_file' do
	assert('app/models/([a-zA-Z0-9_]*)[.]rb',CodeBase::match_spec_from_file('app/models/global.rb'))
end #test
test 'singular_table_from_file' do
	assert('global',CodeBase::singular_table_from_file('app/models/global.rb'))
end #test
test 'file_glob' do
	spec=CodeBase::TABLE_FINDER_REGEXPS[0]
	assert_equal('app/models/global.rb',Dir['app/models/global.rb'][0])
	assert_equal(%{^app/models/([a-zA-Z0-9_]*)[.]rb$},CodeBase.regexp(spec))
	CodeBase::TABLE_FINDER_REGEXPS.map do |spec| 
		assert_not_nil(spec)
		assert_not_nil(spec[:example_file])
		assert_not_nil(CodeBase.file_glob(spec))
	end #map
end #test
test 'regexp' do
#	assert_equal(%{^app/models/([a-z][a-zA-Z0-9_]*)[.]rb$},CodeBase.regexp('app/models/([a-z][a-zA-Z0-9_]*)[.]rb'))
	spec=CodeBase::TABLE_FINDER_REGEXPS[0]
	assert_equal('app/models/global.rb',Dir['app/models/global.rb'][0])
	assert_equal(%{^app/models/([a-zA-Z0-9_]*)[.]rb$},CodeBase.regexp(spec))
	assert_equal('app/models/[a-zA-Z0-9_]*[.]rb',CodeBase.file_glob(spec))
	CodeBase::TABLE_FINDER_REGEXPS.map do |spec| 
		assert_not_nil(spec)
		assert_not_nil(spec[:example_file])
		assert_not_nil(CodeBase.file_glob(spec))
		assert_not_nil(Dir[CodeBase.regexp(spec)])
#		assert_not_empty(Dir[CodeBase.file_glob(spec)],"Dir[#{CodeBase.file_glob(spec)}]=#{Dir[CodeBase.file_glob(spec)]}")
		assert_dir_include(spec[:example_file],CodeBase.file_glob(spec))
		assert_include(spec[:example_file],Dir[CodeBase.file_glob(spec)])
	end #map
end #test
test "git status" do
	assert_equal('global',CodeBase.singular_table_from_file('app/models/global.rb'))
	assert_equal('global',CodeBase.singular_table_from_file('test/unit/global_test.rb'))
	CodeBase::TABLE_FINDER_REGEXPS.each do |match_specs|
		example_file=match_specs[:example_file]
		assert(File.exists?(example_file))
		if !example_file.match(CodeBase.regexp(match_specs)) then
			puts "#{example_file} not \n#{regexp.inspect}"
		else
			#~ puts "#{example_file} matches \n#{regexp.inspect}"
		end #if
	end #each_pair
	CodeBase::TABLE_FINDER_REGEXPS.each do |match_specs|
		example_file=match_specs[:example_file]
		assert(example_file.match(CodeBase.regexp(match_specs)))
	end #each_pair
	#~ CodeBase::TABLE_FINDER_REGEXPS.each do |match_specs|
		#~ example_file=match_specs[:example_file]
		#~ regexp=match_specs[:regexp]
		#~ assert_match(regexp,example_file)
	#~ end #each_pair
	CodeBase::TABLE_FINDER_REGEXPS.each do |match_specs|
		example_file=match_specs[:example_file]
		regexp=match_specs[:regexp]
		assert_not_empty(CodeBase.singular_table_from_file(example_file))
	end #each_pair
	#~ assert_match('app/views/acquisition_stream_specs/_index_partial.html.erb',TABLE_FINDER_REGEXPS['app/views/acquisition_stream_specs/_index_partial.html.erb'])
	assert_equal('acquisition_stream_specs','app/views/acquisition_stream_specs/_index_partial.html.erb'.match(CodeBase.regexp(CodeBase::TABLE_FINDER_REGEXPS[5]))[1])
	assert_equal('acquisition_stream_spec',CodeBase.singular_table_from_file('app/views/acquisition_stream_specs/_index_partial.html.erb'))
	assert_equal('global',CodeBase.singular_table_from_file('app/models/global.rb'))
	assert_not_nil(CodeBase.gitStatus{|status,file| puts "status=#{status}, file=#{file}"})
	file='app/views/acquisition_stream_specs/_index_partial.html.erb'
	assert_not_empty(CodeBase.singular_table_from_file(file))
	assert_nothing_raised{CodeBase.why_not_stage(file,CodeBase.singular_table_from_file(file)) }
	assert_nothing_raised{CodeBase.gitStatus{|status,file| CodeBase.why_not_stage(file,CodeBase.singular_table_from_file(file)) }}
	assert_equal(['global','unit'],CodeBase.table_type_from_source('test/unit/global_test.rb'))
#	assert_nothing_raised{CodeBase.why_not_stage_helper('app/views/acquisition_stream_specs/_index_partial.html.erb',target,sources,test_type)}
	assert_include('app/views/acquisition_stream_specs/index.html.erb',controller_sources('acquisition_stream_spec'))
end #test
test 'why_not_stage_helper' do
end #test
test 'why_not_stage' do
end #test
end #test class
