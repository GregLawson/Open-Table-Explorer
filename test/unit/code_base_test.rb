###########################################################################
#    Copyright (C) 2011 by Greg Lawson                                      
#    <GregLawson@gmail.com>                                                             
#
# Copyright: See COPYING pathname that comes with this distribution
#
###########################################################################
require 'test_helper'
# executed in alphabetical orer? Longer names sort later.
# place in order from low to high level and easy pass to harder, so that first fail is likely the cause.
# move passing tests toward end
require 'test/test_helper_test_tables.rb'
class CodeBaseTest < ActiveSupport::TestCase
require 'lib/tasks/testing.rb'
@@Test_pathname='app/models/code_base.rb'

def test_initialize
	spec=CodeBase.new
	assert_not_nil(spec)
	assert_instance_of(CodeBase, spec)
end #initialize
def test_all
	assert_not_empty(CodeBase.all)
	assert_instance_of(Array,CodeBase.all)
	assert_instance_of(CodeBase,CodeBase.all[0])
end #all
def test_pathname_glob
	spec=CodeBase::TABLE_FINDER_REGEXPS[0]
	assert_equal('app/models/global.rb',Dir['app/models/global.rb'][0])
	assert_equal(%r{^app/models/([a-zA-Z0-9_]*)[.]rb$},CodeBase.regexp(spec))
	CodeBase::TABLE_FINDER_REGEXPS.map do |spec| 
		assert_not_nil(spec)
		assert_not_nil(spec[:example_pathname])
		assert_not_nil(CodeBase.pathname_glob(spec))
	end #map
end #pathname_glob
def test_regexp
#	assert_equal(%r{^app/models/([a-z][a-zA-Z0-9_]*)[.]rb$},CodeBase.regexp('app/models/([a-z][a-zA-Z0-9_]*)[.]rb'))
	spec=CodeBase::TABLE_FINDER_REGEXPS[0]
	assert_equal('app/models/global.rb',Dir['app/models/global.rb'][0])
	assert_equal(%r{^app/models/([a-zA-Z0-9_]*)[.]rb$},CodeBase.regexp(spec))
	assert_equal('app/models/[a-zA-Z0-9_]*[.]rb',CodeBase.pathname_glob(spec))
	CodeBase::TABLE_FINDER_REGEXPS.map do |spec| 
		assert_not_nil(spec)
		assert_not_nil(spec[:example_pathname])
		assert_not_nil(CodeBase.pathname_glob(spec))
		assert_not_nil(Dir[CodeBase.pathname_glob(spec)])
#		assert_not_empty(Dir[CodeBase.pathname_glob(spec)],"Dir[#{CodeBase.pathname_glob(spec)}]=#{Dir[CodeBase.pathname_glob(spec)]}")
		assert_dir_include(spec[:example_pathname],CodeBase.pathname_glob(spec))
		assert_include(spec[:example_pathname],Dir[CodeBase.pathname_glob(spec)])
	end #map
end #regexp
def test_pathnames_from_spec
	CodeBase::TABLE_FINDER_REGEXPS.each do |spec|
		instance=CodeBase.new(spec)
		assert_not_empty(instance.pathnames_from_spec)
	end #each
end #pathnames_from_spec
def test_attribute_assignment
	matched_path_name=MatchedPathName.new(@@Test_pathname)
	assert_instance_of(CodeBase, matched_path_name[:spec])
end #[]=
def test_prioritized_pathname_order
	MatchedPathName.all.each do |matched_path_name|
		assert_instance_of(Array,matched_path_name)
		singular_table=matched_path_name[0]
		assert_not_empty(singular_table)
		assert_not_empty(matched_path_name[1])
		case matched_path_name[1].to_sym
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
			# some other pathname will trigger compilation
		else
			raise "illegal test type=#{test_type}"
		end #case
	end #each
	puts "Most recently modified pathname=#{CodeBase.prioritized_pathname_order{|t,s|[t,s]}.first}"
	CodeBase.prioritized_pathname_order do |target,sources|
		assert_not_nil(target)
		assert_not_nil(sources)
	end #do
	puts "Most recently modified pathname=#{CodeBase.prioritized_pathname_order.first}"
end #prioritized_pathname_order
def test_run_test
end #run_test
def test_not_uptodate_order
	CodeBase.prioritized_pathname_order do |target,sources|
		if CodeBase.uptodate?(target,sources) then
		else
			if !File.exist?(target) then
				puts "#{target} does not exist."
			else
				assert_not_empty(target)
				assert_not_empty(sources)
				not_uptodate_sources=CodeBase.not_uptodate_sources(target,sources)
				puts "#{target.inspect} <- #{not_uptodate_sources.inspect}"
				system ("ls -l #{target}")  # discard result if pathname doesn't exist
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
	puts "Most recently modified up to date pathname=#{CodeBase.not_uptodate_order{|t,s|[t,s]}.first}"
end #not_uptodate_order
def test_test_pathname
end #test_pathname
def CodeBase.model_pathname(singular_table)
end #model_pathname
def test_unit_sources
end #unit_sources
def test_controller_sources
end #controller_sources
def test_unit_target
end #unit_target
def test_controller_target
end #controller_target
def test_model_spec_symbols
	assert_not_empty(CodeBase.model_spec_symbols)
	assert_equal_sets([:models, :unit_tests, :functional_tests, :unit_test_logs, :functional_test_logs,:index_partials, :form_partials, :show_partials, :edit_views, :index_views, :new_views, :show_views, :shared_partials],CodeBase.model_spec_symbols)
end #model_spec_symbols
def test_spec_symbols
	assert_not_empty(CodeBase.spec_symbols)
	assert_equal_sets([:models, :unit_tests, :functional_tests, :unit_test_logs, :functional_test_logs,:index_partials, :form_partials, :show_partials, :edit_views, :index_views, :shared_partials, :new_views, :show_views],CodeBase.spec_symbols)
end #spec_symbols
def test_complete_models
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
def test_spec_from_symbol
	spec_name_symbol=:models
	index=CodeBase::TABLE_FINDER_REGEXPS.index {|s| s[:name]==spec_name_symbol.to_sym}
	assert_instance_of(Fixnum,index)
	assert_instance_of(Hash,CodeBase::TABLE_FINDER_REGEXPS[index])
end #spec_from_symbol
def test_models_from_spec
	CodeBase.model_spec_symbols.each do |spec_name_symbol|
	#	spec_name_symbol=:models
		index=CodeBase::TABLE_FINDER_REGEXPS.index {|s| s[:name]==spec_name_symbol.to_sym}
		spec=CodeBase.spec_from_symbol(spec_name_symbol)
		pathnames=Dir[CodeBase.pathname_glob(spec)]
		assert_not_empty(pathnames)
		models=pathnames.map do |f| 
			assert_instance_of(Regexp, CodeBase.regexp(spec))
			model=f[CodeBase.regexp(spec),1]
			assert_not_nil(model,"pathname=#{f} does not match regexp=#{CodeBase.regexp(spec)}")
			assert_not_empty(model)
			assert_instance_of(String,f[CodeBase.regexp(spec),1])
			assert_not_empty(f[CodeBase.regexp(spec),1])
		end #map
		models=pathnames.map {|f| f[CodeBase.regexp(spec),1] }
		assert_not_empty(models)
		assert_match(/^app\/views\/shared\/_[a-zA-Z0-9_-]*[.]html[.]erb$/,'app/views/shared/_error_messages.html.erb')
		assert_not_empty(CodeBase.models_from_spec(spec_name_symbol))
		assert_include('stream_pattern',CodeBase.models_from_spec(spec_name_symbol))
	end #each
end #models_from_spec
def test_match_spec_from_pathname
	assert('app/models/([a-zA-Z0-9_]*)[.]rb',CodeBase::match_spec_from_pathname('app/models/global.rb'))
end #match_spec_from_pathname
def test_singular_table_from_pathname
	assert('global',CodeBase::singular_table_from_pathname('app/models/global.rb'))
	assert_equal('global',CodeBase.singular_table_from_pathname('app/models/global.rb'))
	assert_equal('global',CodeBase.singular_table_from_pathname('test/unit/global_test.rb'))
	CodeBase::TABLE_FINDER_REGEXPS.each do |spec|

		example_pathname=spec[:example_pathname]
		match_spec=CodeBase.match_spec_from_pathname(example_pathname)
		assert_not_nil(match_spec)
		assert_not_nil(match_spec[:matchData])
		if match_spec.nil? || match_spec[:test_type]==:shared then
			assert_not_nil(match_spec[:matchData][1],"match_spec[:matchData]=#{match_spec[:matchData].inspect}")
			table_name=match_spec[:matchData][1]
			assert_not_nil(table_name)
			assert_not_empty(CodeBase.singular_table_from_pathname(example_pathname),"example_pathname=#{example_pathname}")
		end #if
	end #each
end #singular_table_from_pathname
def test_test_run_from_pathname
end #test_run_from_pathname
def test_test_type_from_source
end #test_type_from_source
def test_test_program_from_pathname
end #test_program_from_pathname
def test_uptodate
# uptodate if target > sources
	target='/proc/bus' # changes often
	sources=['/'] #changes slowly
#	target='/dev/null'
#	sources=['/home/greg/git/development/test/unit/code_base_test.rb']
	assert(CodeBase.uptodate?(target,sources))
end #uptodate
def test_not_uptodate_sources
# not uptodate if sources > target
	sources=['/proc/bus', '/proc/bus']
	target='/'
	assert(CodeBase.not_uptodate_sources(target,sources))
	assert(sources.all?{|s| s.instance_of?(String)} ,"sources=#{sources.inspect} must be an Array of Strings(pathnames)")
#	assert(CodeBase.not_uptodate_sources(target,[]))
end #not_uptodate_sources
def test_git_status
	#~ assert_match('app/views/acquisition_stream_specs/_index_partial.html.erb',TABLE_FINDER_REGEXPS['app/views/acquisition_stream_specs/_index_partial.html.erb'])
#	assert_equal('acquisition_stream_specs','app/views/acquisition_stream_specs/_index_partial.html.erb'.match(CodeBase.regexp(CodeBase::TABLE_FINDER_REGEXPS[5]))[1])
	assert_equal('acquisition_stream_spec',CodeBase.singular_table_from_pathname('app/views/acquisition_stream_specs/_index_partial.html.erb'))
	assert_equal('global',CodeBase.singular_table_from_pathname('app/models/global.rb'))
	assert_not_nil(CodeBase.gitStatus{|status,pathname| puts "status=#{status}, pathname=#{pathname}"})
	pathname='app/views/acquisition_stream_specs/_index_partial.html.erb'
	assert_not_empty(CodeBase.singular_table_from_pathname(pathname))
	assert_nothing_raised{CodeBase.gitStatus{|status,pathname| CodeBase.why_not_stage(pathname,CodeBase.singular_table_from_pathname(pathname)) }}
	assert_equal(['global','unit'],CodeBase.test_type_from_source('test/unit/global_test.rb'))
	assert_include('app/views/acquisition_stream_specs/index.html.erb',CodeBase.controller_sources('acquisition_stream_spec'))
end #git_status
def test_why_not_stage_helper
end #why_not_stage_helper
def test_why_not_stage
	pathname='app/views/acquisition_stream_specs/_index_partial.html.erb'
	assert_nothing_raised{CodeBase.why_not_stage(pathname,CodeBase.singular_table_from_pathname(pathname)) }
#	assert_nothing_raised{CodeBase.why_not_stage_helper('app/views/acquisition_stream_specs/_index_partial.html.erb',target,sources,test_type)}
end #why_not_stage_helper
def test_rails_MVC_classes
	assert_include(StreamMethod,CodeBase.rails_MVC_classes)
	assert_not_include(Generic_Table,CodeBase.rails_MVC_classes)
	assert_not_include(CodeBase,CodeBase.rails_MVC_classes)
	assert_not_include(MethodModel,CodeBase.rails_MVC_classes)
end #rails_MVC_classes
def test_example_pathnames_exist
	CodeBase::TABLE_FINDER_REGEXPS.each do |spec|
		example_pathname=spec[:example_pathname]
		assert(File.exists?(example_pathname))
		if !example_pathname.match(CodeBase.regexp(spec)) then
			puts "#{example_pathname} not \n#{regexp.inspect}"
		else
			#~ puts "#{example_pathname} matches \n#{regexp.inspect}"
		end #if
	end #each_pair
end #example_pathnames_exist
def test_example_pathnames_match_regexp
	CodeBase::TABLE_FINDER_REGEXPS.each do |spec|
		example_pathname=spec[:example_pathname]
		assert(example_pathname.match(CodeBase.regexp(spec)))
	end #each_pair
	CodeBase::TABLE_FINDER_REGEXPS.each do |spec|
		example_pathname=spec[:example_pathname]
		regexp=CodeBase.regexp(spec)
		assert_match(regexp,example_pathname,"example_pathname=#{example_pathname}, regexp=#{regexp}")
	end #each
end #example_pathnames_match_regexp
def test_globs_match_regexp
	CodeBase::TABLE_FINDER_REGEXPS.each do |spec|
		pathnames=Dir[CodeBase.pathname_glob(spec)]
		if pathnames.nil? then
			raise "#{CodeBase.pathname_glob(spec)} does not match any pathnames."
		end #if
		regexp=CodeBase.regexp(spec)
		pathnames.each do |pathname|
			assert_match(regexp,pathname,"pathname=#{pathname}, regexp=#{regexp}")
		end #each
	end #each

end #globs_match_regexp
end #CodeBase
class CodeBaseTest < ActiveSupport::TestCase
require 'lib/tasks/testing.rb'
def test_MatchedPathName
	matched_path_name=MatchedPathName.new(@@Test_pathname)
	assert_equal(@@Test_pathname,matched_path_name[:pathname])
	assert_equal(@@Test_pathname,matched_path_name['pathname'])
	assert_equal(@@Test_pathname,matched_path_name[:matchData][0])
	assert_equal(:models,matched_path_name[:spec][:name])
	assert_instance_of(MatchedPathName,matched_path_name)

	assert_attribute_of(matched_path_name, :pathname, String)
	assert_attribute_of(matched_path_name, :matchData, MatchData)
	assert_attribute_of(matched_path_name[:spec], :name, Symbol)
	assert_attribute_of(MatchedPathName.new(@@Test_pathname), :spec, ActiveSupport::HashWithIndifferentAccess)
	CodeBase.all.each do |spec|
		assert_not_nil(spec)
		assert_instance_of(CodeBase, spec)
		matchData=@@Test_pathname.match(spec[:Dir_glob])
		if matchData then
			matched_path_name[:matchData]=matchData # add match data found
			matched_path_name[:spec]=spec
			assert_instance_of(CodeBase, spec)
			spec2=spec
			assert_instance_of(CodeBase, spec2)
			assert_instance_of(CodeBase, matched_path_name[:spec])
			assert_attribute_of(matched_path_name, :spec, CodeBase)
		end #if
	end #each

	assert_attribute_of(MatchedPathName.new('/dev/null', matched_path_name[:spec]), :spec, CodeBase)
	assert_attribute_of(MatchedPathName.new(@@Test_pathname, matched_path_name[:spec]), :spec, CodeBase)
	assert_attribute_of(matched_path_name, :spec, CodeBase)

	matched_path_name=MatchedPathName.new(@@Test_pathname, matched_path_name[:spec])
	assert_instance_of(MatchedPathName,matched_path_name)
	assert_instance_of(CodeBase,matched_path_name[:spec])
	matched_path_name=MatchedPathName.new(@@Test_pathname)
	assert_instance_of(CodeBase,matched_path_name[:spec])
end #initialize MatchedPathName
def test_all_model_specfic_pathnames
end #all_model_specfic_pathnames
def test_all_model_specfic_pathnames
	assert_instance_of(Array,MatchedPathName.all)
	assert_instance_of(MatchedPathName,MatchedPathName.all[0])
	all=MatchedPathName.all
	assert_not_empty(all)
end #all
def test_all_tests
	ret=MatchedPathName.all.select {|match| match[:test_type]=:unit}
	assert_not_empty(ret)
	assert_not_empty(MatchedPathName.all.select {|match| match[:test_type]=:unit})
	assert_not_empty(MatchedPathName.all.select {|match| match[:test_type]=:controller})
	assert_not_empty(MatchedPathName.all.select {|match| match[:test_type]=:both})
end #all_tests
def test_suggest_test_runs
	matched_path_name=MatchedPathName.new(@@Test_pathname)
	assert_instance_of(MatchedPathName,matched_path_name[:spec])
	assert_not_nil(matched_path_name)
	test_runs=matched_path_name.suggest_test_runs
	assert_not_empty(test_runs)
end #suggest_test_runs
def test_name_plurality
	assert_not_nil(CodeBase.spec_from_symbol(:shared_partials))
	assert_not_nil(CodeBase.spec_from_symbol(:models))
	matched_path_name=MatchedPathName.new(@@Test_pathname)
	assert_equal('code_base',matched_path_name.name_plurality[:singular])
	assert_equal('code_bases',matched_path_name.name_plurality[:plural])
end #name_plurality
end #MatchedPathName