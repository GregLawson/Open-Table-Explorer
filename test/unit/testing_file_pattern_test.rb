require 'test_helper'
require 'lib/tasks/testing_file_patterns.rb'
# executed in alphabetical orer? Longer names sort later.
# place in order from low to high level and easy pass to harder, so that first fail is likely the cause.
# move passing tests toward end
require 'test/test_helper_test_tables.rb'
class TestingFilePatternsTest < ActiveSupport::TestCase
require 'lib/tasks/testing.rb'
test 'example_files exist' do
	CodeBase::TABLE_FINDER_REGEXPS.each do |spec|
		example_file=spec[:example_file]
		assert(File.exists?(example_file))
		if !example_file.match(CodeBase.regexp(spec)) then
			puts "#{example_file} not \n#{regexp.inspect}"
		else
			#~ puts "#{example_file} matches \n#{regexp.inspect}"
		end #if
	end #each_pair
end #test
test 'example files match regexp' do
	CodeBase::TABLE_FINDER_REGEXPS.each do |spec|
		example_file=spec[:example_file]
		assert(example_file.match(CodeBase.regexp(spec)))
	end #each_pair
	CodeBase::TABLE_FINDER_REGEXPS.each do |spec|
		example_file=spec[:example_file]
		regexp=CodeBase.regexp(spec)
		assert_match(regexp,example_file,"example_file=#{example_file}, regexp=#{regexp}")
	end #each
end #test
test 'globs match regexp' do
	CodeBase::TABLE_FINDER_REGEXPS.each do |spec|
		files=Dir[CodeBase.file_glob(spec)]
		if files.nil? then
			raise "#{CodeBase.file_glob(spec)} does not match any files."
		end #if
		regexp=CodeBase.regexp(spec)
		files.each do |file|
			assert_match(regexp,file,"file=#{file}, regexp=#{regexp}")
		end #each
	end #each

end #test
test 'model_spec_symbols' do
	assert_not_empty(CodeBase.model_spec_symbols)
	assert_equal_sets([:models, :unit_tests, :functional_tests, :unit_test_logs, :functional_test_logs,:index_partials, :form_partials, :show_partials, :edit_views, :index_views, :new_views, :show_views],CodeBase.model_spec_symbols)
end #def
test 'spec_symbols' do
	assert_not_empty(CodeBase.spec_symbols)
	assert_equal_sets([:models, :unit_tests, :functional_tests, :unit_test_logs, :functional_test_logs,:index_partials, :form_partials, :show_partials, :edit_views, :index_views, :shared_partials, :new_views, :show_views],CodeBase.spec_symbols)
end #def
test 'complete_models' do
	list_of_model_sets=CodeBase.model_spec_symbols.map {|spec_name_symbol| CodeBase.models_from_spec(spec_name_symbol)}
	assert_not_empty(list_of_model_sets)
	assert_not_equal(Set[nil],CodeBase.models_from_spec(:models))
	assert_not_equal(Set[nil],CodeBase.models_from_spec(:unit_tests))
	assert_not_equal(Set[nil],CodeBase.models_from_spec(:functional_tests))
	assert_not_equal(Set[nil],CodeBase.models_from_spec(:unit_test_logs))
	assert_not_equal(Set[nil],CodeBase.models_from_spec(:functional_test_logs))
	assert_not_equal(Set[nil],CodeBase.models_from_spec(:index_partials))
	assert_not_equal(Set[nil],CodeBase.models_from_spec(:form_partials))
	assert_not_equal(Set[nil],CodeBase.models_from_spec(:show_partials))
	assert_not_equal(Set[nil],CodeBase.models_from_spec(:edit_views))
	assert_not_equal(Set[nil],CodeBase.models_from_spec(:index_views))
	assert_raise(RuntimeError,'shared_partials has no models.'){assert_not_empty(CodeBase.models_from_spec(:shared_partials))}
	assert_not_equal(Set[nil],CodeBase.models_from_spec(:new_views))
	assert_not_equal(Set[nil],CodeBase.models_from_spec(:show_views))
	assert_not_equal(Set[nil],CodeBase.models_from_spec(:unit_test_logs))
	assert_not_equal(Set[nil],CodeBase.models_from_spec(:unit_test_logs))
#	assert_equal(Set[],CodeBase.models_from_spec(:unit_test_logs))
	assert_overlap(CodeBase.models_from_spec(:functional_tests),CodeBase.models_from_spec(:unit_test_logs))
	assert_overlap(CodeBase.models_from_spec(:unit_test_logs),CodeBase.models_from_spec(:functional_test_logs))
	assert_overlap(CodeBase.models_from_spec(:functional_test_logs),CodeBase.models_from_spec(:index_partials))
	assert_overlap(CodeBase.models_from_spec(:index_partials),CodeBase.models_from_spec(:models))
	assert_overlap(CodeBase.models_from_spec(:models),CodeBase.models_from_spec(:unit_tests))
	assert_overlap(CodeBase.models_from_spec(:unit_tests),CodeBase.models_from_spec(:functional_tests))
	assert_not_empty(list_of_model_sets.reduce(:&))
	assert_not_empty(CodeBase.complete_models)
end #def
test 'spec_from_symbol' do
	spec_name_symbol=:models
	index=CodeBase::TABLE_FINDER_REGEXPS.index {|s| s[:name]==spec_name_symbol.to_sym}
	assert_instance_of(Fixnum,index)
	assert_instance_of(Hash,CodeBase::TABLE_FINDER_REGEXPS[index])
end #test
test 'models_from_spec' do
	CodeBase.model_spec_symbols.each do |spec_name_symbol|
	#	spec_name_symbol=:models
		index=CodeBase::TABLE_FINDER_REGEXPS.index {|s| s[:name]==spec_name_symbol.to_sym}
		spec=CodeBase.spec_from_symbol(spec_name_symbol)
		files=Dir[CodeBase.file_glob(spec)]
		assert_not_empty(files)
		models=files.map do |f| 
			assert_instance_of(Regexp, CodeBase.regexp(spec))
			model=f[CodeBase.regexp(spec),1]
			assert_not_nil(model,"file=#{f} does not match regexp=#{CodeBase.regexp(spec)}")
			assert_not_empty(model)
			assert_instance_of(String,f[CodeBase.regexp(spec),1])
			assert_not_empty(f[CodeBase.regexp(spec),1])
		end #map
		models=files.map {|f| f[CodeBase.regexp(spec),1] }
		assert_not_empty(models)
		assert_match(/^app\/views\/shared\/_[a-zA-Z0-9_-]*[.]html[.]erb$/,'app/views/shared/_error_messages.html.erb')
		assert_not_equal(Set[nil],CodeBase.models_from_spec(spec_name_symbol))
		assert_include('stream_pattern',CodeBase.models_from_spec(spec_name_symbol))
	end #each
end #test
test 'match_spec_from_file' do
	assert('app/models/([a-zA-Z0-9_]*)[.]rb',CodeBase::match_spec_from_file('app/models/global.rb'))
end #test
test 'singular_table_from_file' do
	assert('global',CodeBase::singular_table_from_file('app/models/global.rb'))
	assert_equal('global',CodeBase.singular_table_from_file('app/models/global.rb'))
	assert_equal('global',CodeBase.singular_table_from_file('test/unit/global_test.rb'))
	CodeBase::TABLE_FINDER_REGEXPS.each do |spec|

		example_file=spec[:example_file]
		match_spec=CodeBase.match_spec_from_file(example_file)
		assert_not_nil(match_spec)
		assert_not_nil(match_spec[:matchData])
		if spec[:test_type]!=:shared then
			assert_not_nil(match_spec[:matchData][1],"match_spec[:matchData]=#{match_spec[:matchData].inspect}")
			table_name=match_spec[:matchData][1]
			assert_not_nil(table_name)
			assert_not_empty(CodeBase.singular_table_from_file(example_file),"example_file=#{example_file}")
		end #if
	end #each
end #test
test 'file_glob' do
	spec=CodeBase::TABLE_FINDER_REGEXPS[0]
	assert_equal('app/models/global.rb',Dir['app/models/global.rb'][0])
	assert_equal(%r{^app/models/([a-zA-Z0-9_]*)[.]rb$},CodeBase.regexp(spec))
	CodeBase::TABLE_FINDER_REGEXPS.map do |spec| 
		assert_not_nil(spec)
		assert_not_nil(spec[:example_file])
		assert_not_nil(CodeBase.file_glob(spec))
	end #map
end #test
test 'regexp' do
#	assert_equal(%r{^app/models/([a-z][a-zA-Z0-9_]*)[.]rb$},CodeBase.regexp('app/models/([a-z][a-zA-Z0-9_]*)[.]rb'))
	spec=CodeBase::TABLE_FINDER_REGEXPS[0]
	assert_equal('app/models/global.rb',Dir['app/models/global.rb'][0])
	assert_equal(%r{^app/models/([a-zA-Z0-9_]*)[.]rb$},CodeBase.regexp(spec))
	assert_equal('app/models/[a-zA-Z0-9_]*[.]rb',CodeBase.file_glob(spec))
	CodeBase::TABLE_FINDER_REGEXPS.map do |spec| 
		assert_not_nil(spec)
		assert_not_nil(spec[:example_file])
		assert_not_nil(CodeBase.file_glob(spec))
		assert_not_nil(Dir[CodeBase.file_glob(spec)])
#		assert_not_empty(Dir[CodeBase.file_glob(spec)],"Dir[#{CodeBase.file_glob(spec)}]=#{Dir[CodeBase.file_glob(spec)]}")
		assert_dir_include(spec[:example_file],CodeBase.file_glob(spec))
		assert_include(spec[:example_file],Dir[CodeBase.file_glob(spec)])
	end #map
end #test
test "git status" do
	#~ assert_match('app/views/acquisition_stream_specs/_index_partial.html.erb',TABLE_FINDER_REGEXPS['app/views/acquisition_stream_specs/_index_partial.html.erb'])
#	assert_equal('acquisition_stream_specs','app/views/acquisition_stream_specs/_index_partial.html.erb'.match(CodeBase.regexp(CodeBase::TABLE_FINDER_REGEXPS[5]))[1])
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
