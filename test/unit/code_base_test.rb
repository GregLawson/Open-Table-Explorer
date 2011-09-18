require 'test_helper'
#require 'lib/tasks/testing_file_patterns.rb'
# executed in alphabetical orer? Longer names sort later.
# place in order from low to high level and easy pass to harder, so that first fail is likely the cause.
# move passing tests toward end
require 'test/test_helper_test_tables.rb'
class TestingFilePatternsTest < ActiveSupport::TestCase
require 'lib/tasks/testing.rb'
test 'file_glob' do
	spec=CodeBase::TABLE_FINDER_REGEXPS[0]
	assert_equal('app/models/global.rb',Dir['app/models/global.rb'][0])
	assert_equal(%r{^app/models/([a-zA-Z0-9_]*)[.]rb$},CodeBase.regexp(spec))
	CodeBase::TABLE_FINDER_REGEXPS.map do |spec| 
		assert_not_nil(spec)
		assert_not_nil(spec[:example_file])
		assert_not_nil(CodeBase.file_glob(spec))
	end #map
end #file_glob
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
end #regexp
test 'files_from_spec' do
	CodeBase::TABLE_FINDER_REGEXPS.each do |spec|
		instance=CodeBase.new(spec)
		assert_not_empty(instance.files_from_spec)
	end #each
end #files_from_spec
test 'all_model_specfic_files' do
	assert_not_empty(CodeBase.all_model_specfic_files)
	assert_instance_of(Array,CodeBase.all_model_specfic_files)
	assert_instance_of(Hash,CodeBase.all_model_specfic_files[0])
end #all_model_specfic_files
test 'prioritized_file_order' do
	file_type_pairs=CodeBase::FILE_MOD_TIMES.map do |file_and_spec|
		assert_not_empty(file_and_spec[:spec])
		assert_instance_of(Regexp,CodeBase.regexp(file_and_spec[:spec]))
		assert_include(file_and_spec[:spec][:test_type],[:unit,:controller,:both,:shared])
		if file_and_spec[:spec][:test_type]!=:shared then
			singular_table=CodeBase.singular_table_from_file(file_and_spec[:file])
			assert_not_nil(singular_table)
			assert_not_empty(singular_table,"file_and_spec=#{file_and_spec.inspect}")
			assert_not_nil(file_and_spec[:file][CodeBase.regexp(file_and_spec[:spec]),1],"file_and_spec=#{file_and_spec.inspect}")
			assert_not_empty(file_and_spec[:file][CodeBase.regexp(file_and_spec[:spec]),1],"file_and_spec=#{file_and_spec.inspect}")
		end #if
		assert_not_nil(file_and_spec[:spec][:test_type])
		[singular_table,file_and_spec[:spec][:test_type].to_s]
	end #map
	file_type_pairs.each do |file_and_type|
		assert_instance_of(Array,file_and_type)
		singular_table=file_and_type[0]
		assert_not_empty(singular_table)
		assert_not_empty(file_and_type[1])
		case file_and_type[1].to_sym
		when :unit
			assert_not_empty(CodeBase.unit_target(singular_table))
			assert_not_empty(CodeBase.unit_sources(singular_table))
#			process_test.call(CodeBase.unit_target(singular_table), CodeBase.unit_sources(singular_table))
		when :controller
#			process_test.call(CodeBase.controller_target(singular_table), CodeBase.controller_sources(singular_table))
		when :both
			assert_not_empty(CodeBase.unit_target(singular_table))
			assert_not_empty(CodeBase.unit_sources(singular_table))
#			process_test.call(CodeBase.unit_target(singular_table), CodeBase.unit_sources(singular_table)) &&
			assert_not_empty(CodeBase.controller_target(singular_table))
			assert_not_empty(CodeBase.controller_sources(singular_table))
#			process_test.call(CodeBase.controller_target(singular_table), CodeBase.controller_sources(singular_table))
		when :shared
			# some other file will trigger compilation
		else
			raise "illegal test type=#{test_type}"
		end #case
	end #each
	puts "Most recently modified file=#{CodeBase.prioritized_file_order{|t,s|[t,s]}.first}"
	CodeBase.prioritized_file_order do |target,sources|
		assert_not_nil(target)
		assert_not_nil(sources)
	end #do
	puts "Most recently modified file=#{CodeBase.prioritized_file_order.first}"
end #prioritized_file_order
test 'run_test' do
end #run_test
test 'not_uptodate_order' do
	CodeBase.prioritized_file_order do |target,sources|
		if CodeBase.uptodate?(target,sources) then
		else
			if !File.exist?(target) then
				puts "#{target} does not exist."
			else
				assert_not_empty(target)
				assert_not_empty(sources)
				not_uptodate_sources=CodeBase.not_uptodate_sources(target,sources)
				puts "#{target.inspect} <- #{not_uptodate_sources.inspect}"
				system ("ls -l #{target}")  # discard result if file doesn't exist
				not_uptodate_sources.each do |s|
					if !CodeBase.uptodate?(target, [s])  then
						puts "not up to date."
						if !File.exist?(s) then
							puts "#{s} does not exist."
						end #if
						system "ls -l #{s}"
					end #if
				end #each
			end #if
		end #if
	end #do
	CodeBase.not_uptodate_order do 
	end #not_uptodate_order
	puts "Most recently modified up to date file=#{CodeBase.not_uptodate_order{|t,s|[t,s]}.first}"
end #not_uptodate_order
def CodeBase.test_file(singular_table, test_type)
end #test_file
def CodeBase.model_file(singular_table)
end #model_file
test 'unit_sources' do
end #unit_sources
test 'controller_sources' do
end #controller_sources
test 'unit_target' do
end #unit_target
test 'controller_target' do
end #controller_target
test 'model_spec_symbols' do
	assert_not_empty(CodeBase.model_spec_symbols)
	assert_equal_sets([:models, :unit_tests, :functional_tests, :unit_test_logs, :functional_test_logs,:index_partials, :form_partials, :show_partials, :edit_views, :index_views, :new_views, :show_views],CodeBase.model_spec_symbols)
end #model_spec_symbols
test 'spec_symbols' do
	assert_not_empty(CodeBase.spec_symbols)
	assert_equal_sets([:models, :unit_tests, :functional_tests, :unit_test_logs, :functional_test_logs,:index_partials, :form_partials, :show_partials, :edit_views, :index_views, :shared_partials, :new_views, :show_views],CodeBase.spec_symbols)
end #spec_symbols
test 'complete_models' do
	list_of_model_sets=CodeBase.model_spec_symbols.map {|spec_name_symbol| CodeBase.models_from_spec(spec_name_symbol)}
	assert_not_empty(list_of_model_sets)
	assert_not_empty(CodeBase.models_from_spec(:models))
	assert_not_empty(CodeBase.models_from_spec(:unit_tests))
	assert_not_empty(CodeBase.models_from_spec(:functional_tests))
	assert_not_empty(CodeBase.models_from_spec(:unit_test_logs))
	assert_not_empty(CodeBase.models_from_spec(:functional_test_logs))
	assert_not_empty(CodeBase.models_from_spec(:index_partials))
	assert_not_empty(CodeBase.models_from_spec(:form_partials))
	assert_not_empty(CodeBase.models_from_spec(:show_partials))
	assert_not_empty(CodeBase.models_from_spec(:edit_views))
	assert_not_empty(CodeBase.models_from_spec(:index_views))
	assert_raise(RuntimeError,'shared_partials has no models.'){assert_not_empty(CodeBase.models_from_spec(:shared_partials))}
	assert_not_empty(CodeBase.models_from_spec(:new_views))
	assert_not_empty(CodeBase.models_from_spec(:show_views))
	assert_not_empty(CodeBase.models_from_spec(:unit_test_logs))
	assert_not_empty(CodeBase.models_from_spec(:unit_test_logs))
#	assert_equal(Set[],CodeBase.models_from_spec(:unit_test_logs))
	assert_overlap(CodeBase.models_from_spec(:functional_tests),CodeBase.models_from_spec(:unit_test_logs))
	assert_overlap(CodeBase.models_from_spec(:unit_test_logs),CodeBase.models_from_spec(:functional_test_logs))
	assert_overlap(CodeBase.models_from_spec(:functional_test_logs),CodeBase.models_from_spec(:index_partials))
	assert_overlap(CodeBase.models_from_spec(:index_partials),CodeBase.models_from_spec(:models))
	assert_overlap(CodeBase.models_from_spec(:models),CodeBase.models_from_spec(:unit_tests))
	assert_overlap(CodeBase.models_from_spec(:unit_tests),CodeBase.models_from_spec(:functional_tests))
	assert_not_empty(list_of_model_sets.reduce(:&))
	assert_not_empty(CodeBase.complete_models)
end #complete_models
test 'spec_from_symbol' do
	spec_name_symbol=:models
	index=CodeBase::TABLE_FINDER_REGEXPS.index {|s| s[:name]==spec_name_symbol.to_sym}
	assert_instance_of(Fixnum,index)
	assert_instance_of(Hash,CodeBase::TABLE_FINDER_REGEXPS[index])
end #spec_from_symbol
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
		assert_not_empty(CodeBase.models_from_spec(spec_name_symbol))
		assert_include('stream_pattern',CodeBase.models_from_spec(spec_name_symbol))
	end #each
end #models_from_spec
test 'match_spec_from_file' do
	assert('app/models/([a-zA-Z0-9_]*)[.]rb',CodeBase::match_spec_from_file('app/models/global.rb'))
end #match_spec_from_file
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
end #singular_table_from_file
test 'name_plurality_from_file' do
end #test_run_from_file
test 'test_type_from_source' do
end #test_type_from_source
test 'test_program_from_file' do
end #test_program_from_file
test 'uptodate' do
# uptodate if target > sources
	target='/proc/bus' # changes often
	sources=['/'] #changes slowly
#	target='/dev/null'
#	sources=['/home/greg/git/development/test/unit/code_base_test.rb']
assert(CodeBase.uptodate?(target,sources))
end #uptodate
test 'not_uptodate_sources' do
# not uptodate if sources > target
	sources=['/proc/bus', '/proc/bus']
	target='/'
	assert(CodeBase.not_uptodate_sources(target,sources))
	assert(sources.all?{|s| s.instance_of?(String)} ,"sources=#{sources.inspect} must be an Array of Strings(pathnames)")
end #not_uptodate_sources
test "git_status" do
	#~ assert_match('app/views/acquisition_stream_specs/_index_partial.html.erb',TABLE_FINDER_REGEXPS['app/views/acquisition_stream_specs/_index_partial.html.erb'])
#	assert_equal('acquisition_stream_specs','app/views/acquisition_stream_specs/_index_partial.html.erb'.match(CodeBase.regexp(CodeBase::TABLE_FINDER_REGEXPS[5]))[1])
	assert_equal('acquisition_stream_spec',CodeBase.singular_table_from_file('app/views/acquisition_stream_specs/_index_partial.html.erb'))
	assert_equal('global',CodeBase.singular_table_from_file('app/models/global.rb'))
	assert_not_nil(CodeBase.gitStatus{|status,file| puts "status=#{status}, file=#{file}"})
	file='app/views/acquisition_stream_specs/_index_partial.html.erb'
	assert_not_empty(CodeBase.singular_table_from_file(file))
	assert_nothing_raised{CodeBase.gitStatus{|status,file| CodeBase.why_not_stage(file,CodeBase.singular_table_from_file(file)) }}
	assert_equal(['global','unit'],CodeBase.test_type_from_source('test/unit/global_test.rb'))
	assert_include('app/views/acquisition_stream_specs/index.html.erb',CodeBase.controller_sources('acquisition_stream_spec'))
end #git_status
test 'why_not_stage_helper' do
end #why_not_stage_helper
test 'why_not_stage' do
	file='app/views/acquisition_stream_specs/_index_partial.html.erb'
	assert_nothing_raised{CodeBase.why_not_stage(file,CodeBase.singular_table_from_file(file)) }
#	assert_nothing_raised{CodeBase.why_not_stage_helper('app/views/acquisition_stream_specs/_index_partial.html.erb',target,sources,test_type)}
end #why_not_stage_helper
test 'example_files_exist' do
	CodeBase::TABLE_FINDER_REGEXPS.each do |spec|
		example_file=spec[:example_file]
		assert(File.exists?(example_file))
		if !example_file.match(CodeBase.regexp(spec)) then
			puts "#{example_file} not \n#{regexp.inspect}"
		else
			#~ puts "#{example_file} matches \n#{regexp.inspect}"
		end #if
	end #each_pair
end #example_files_exist
test 'example_files_match_regexp' do
	CodeBase::TABLE_FINDER_REGEXPS.each do |spec|
		example_file=spec[:example_file]
		assert(example_file.match(CodeBase.regexp(spec)))
	end #each_pair
	CodeBase::TABLE_FINDER_REGEXPS.each do |spec|
		example_file=spec[:example_file]
		regexp=CodeBase.regexp(spec)
		assert_match(regexp,example_file,"example_file=#{example_file}, regexp=#{regexp}")
	end #each
end #example_files_match_regexp
test 'globs_match_regexp' do
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

end #globs_match_regexp
test 'stuck' do
end #
end #CodeBase
