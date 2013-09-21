###########################################################################
#    Copyright (C) 2011-2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING pathname that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
# executed in alphabetical order. Longer names sort later.
# place in order from low to high level and easy pass to harder, so that first fail is likely the cause.
# move passing tests toward end
#require_relative '../assertions/generic_table_examples.rb'
require_relative '../../app/models/code_base.rb'
class CodeBaseTest < TestCase
require_relative '../../lib/tasks/testing.rb'
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
	spec=CodeBase.all[0]
	assert_equal('app/models/global.rb',Dir['app/models/global.rb'][0])
	assert_equal(%r{^app/models/([a-zA-Z0-9_]*)[.]rb$},spec.regexp)
	CodeBase.all.map do |spec| 
		assert_not_nil(spec)
		assert_not_nil(spec[:example_pathname])
		assert_not_nil(spec.pathname_glob)
	end #map
	spec=CodeBase.all[0]
	assert_equal('app/models/*[.]rb',spec.pathname_glob)
	assert_equal('test/*[.]r*', RegexpTree.new('test/[a-zA-Z0-9_]*[.]r[a-z]*').to_pathname_glob)
	assert_equal('test/*[.]r*', CodeBase.find_by_name(:testing).pathname_glob)
end #pathname_glob
def test_regexp
#	assert_equal(%r{^app/models/([a-z][a-zA-Z0-9_]*)[.]rb$},CodeBase.regexp('app/models/([a-z][a-zA-Z0-9_]*)[.]rb'))
	spec=CodeBase.all[0]
	assert_equal('app/models/global.rb',Dir['app/models/global.rb'][0])
	assert_equal(%r{^app/models/([a-zA-Z0-9_]*)[.]rb$},spec.regexp)
	assert_equal('app/models/*[.]rb',spec.pathname_glob)
	CodeBase.all.map do |spec| 
		assert_not_nil(spec)
		assert_not_nil(spec[:example_pathname])
		assert_not_nil(spec.pathname_glob)
		assert_not_nil(Dir[spec.pathname_glob])
#		assert_not_empty(Dir[spec.pathname_glob],"Dir[#{spec.pathname_glob}]=#{Dir[spec.pathname_glob]}")
		assert_dir_include(spec[:example_pathname],spec.pathname_glob)
		assert_include(spec[:example_pathname],Dir[spec.pathname_glob])
	end #map
end #regexp
def test_pathnames
	CodeBase.all.each do |spec|
		assert_not_empty(spec.pathnames,"No pathnames found for spec=#{spec.inspect}")
	end #each
end #pathnames
def test_attribute_assignment
	matched_path_name=MatchedPathName.new(@@Test_pathname)
	assert_instance_of(CodeBase, matched_path_name[:spec])
end #[]=
def test_test_pathname
end #test_pathname
def test_model_pathname
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
	assert_equal_sets([:unit_tests, :functional_tests, :unit_test_logs, :functional_test_logs,:index_partials, :form_partials, :show_partials, :edit_views, :index_views, :new_views, :show_views, :shared_partials, :controllers],CodeBase.model_spec_symbols)
end #model_spec_symbols
def test_spec_symbols
	assert_not_empty(CodeBase.spec_symbols)
	assert_equal_sets([:models, :testing, :unit_tests, :functional_tests, :unit_test_logs, :functional_test_logs,:index_partials, :form_partials, :show_partials, :edit_views, :index_views, :new_views, :show_views, :shared_partials, :controllers],CodeBase.spec_symbols)
end #spec_symbols
def test_find_by_name
	assert_not_nil(CodeBase.find_by_name(:models))
	assert_not_nil(CodeBase.find_by_name(:unit_tests))
	assert_not_nil(CodeBase.find_by_name(:functional_tests))
	assert_not_nil(CodeBase.find_by_name(:unit_test_logs))
	assert_not_nil(CodeBase.find_by_name(:functional_test_logs))
	assert_not_nil(CodeBase.find_by_name(:index_partials))
	assert_not_nil(CodeBase.find_by_name(:form_partials))
	assert_not_nil(CodeBase.find_by_name(:show_partials))
	assert_not_nil(CodeBase.find_by_name(:edit_views))
	assert_not_nil(CodeBase.find_by_name(:index_views))
	assert_not_nil(CodeBase.find_by_name(:shared_partials).models, 'shared_partials has no models.')
	assert_not_nil(CodeBase.find_by_name(:new_views))
	assert_not_nil(CodeBase.find_by_name(:show_views))
	assert_not_nil(CodeBase.find_by_name(:unit_test_logs))
	assert_not_nil(CodeBase.find_by_name(:unit_test_logs))

	assert_instance_of(CodeBase, CodeBase.find_by_name(:models))
	assert_instance_of(CodeBase, CodeBase.find_by_name(:unit_tests))
	assert_instance_of(CodeBase, CodeBase.find_by_name(:functional_tests))
	assert_instance_of(CodeBase, CodeBase.find_by_name(:unit_test_logs))
	assert_instance_of(CodeBase, CodeBase.find_by_name(:functional_test_logs))
	assert_instance_of(CodeBase, CodeBase.find_by_name(:index_partials))
	assert_instance_of(CodeBase, CodeBase.find_by_name(:form_partials))
	assert_instance_of(CodeBase, CodeBase.find_by_name(:show_partials))
	assert_instance_of(CodeBase, CodeBase.find_by_name(:edit_views))
	assert_instance_of(CodeBase, CodeBase.find_by_name(:index_views))
	assert_instance_of(CodeBase, CodeBase.find_by_name(:shared_partials), 'shared_partials has no models.')
	assert_instance_of(CodeBase, CodeBase.find_by_name(:new_views))
	assert_instance_of(CodeBase, CodeBase.find_by_name(:show_views))
	assert_instance_of(CodeBase, CodeBase.find_by_name(:unit_test_logs))
	assert_instance_of(CodeBase, CodeBase.find_by_name(:unit_test_logs))
end #find_by_name
def pathnames_with_models?
	assert_equal(false, CodeBase.find_by_name(:index_partials).pathnames_with_models?)
	assert_equal(false, CodeBase.find_by_name(:testing).pathnames_with_models?)
	assert_equal(true, CodeBase.find_by_name(:models).pathnames_with_models?)
end #pathnames_with_models
def test_models
#	assert_equal(Set[],CodeBase.find_by_name(:unit_test_logs).models)
	assert_overlap(CodeBase.find_by_name(:functional_tests).models,CodeBase.find_by_name(:unit_test_logs).models)
	assert_overlap(CodeBase.find_by_name(:unit_test_logs).models,CodeBase.find_by_name(:functional_test_logs).models)
	assert_overlap(CodeBase.find_by_name(:functional_test_logs).models,CodeBase.find_by_name(:index_partials).models)
	assert_overlap(CodeBase.find_by_name(:index_partials).models,CodeBase.find_by_name(:models).models)
	assert_overlap(CodeBase.find_by_name(:models).models,CodeBase.find_by_name(:unit_tests).models)
	assert_overlap(CodeBase.find_by_name(:unit_tests).models,CodeBase.find_by_name(:functional_tests).models)
	CodeBase.all.each do |spec|
		pathnames=Dir[spec.pathname_glob]
		assert_not_empty(pathnames)
		models=pathnames.map do |f| 
			assert_instance_of(Regexp, spec.regexp)
			model=f[spec.regexp,1]
			if model.nil? then
				assert_include(spec[:name], [:shared_partials,:testing], "model should not (regexp=#{spec.regexp}) be embedded in pathname (#{f}).")
			else
				assert_instance_of(String,f[spec.regexp,1])
				assert_not_nil(model,"pathname=#{f} does not match regexp=#{spec.regexp}")
				assert_not_empty(model)
				assert_not_empty(f[spec.regexp,1])
				assert_include('stream_pattern',spec.models)
			end #if
		end #map
		models=pathnames.map {|f| f[spec.regexp,1] }
		assert_not_empty(models)
		assert_match(/^app\/views\/shared\/_[a-zA-Z0-9_-]*[.]html[.]erb$/,'app/views/shared/_error_messages.html.erb')
	end #each
end #models
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
#	assert_equal('acquisition_stream_specs','app/views/acquisition_stream_specs/_index_partial.html.erb'.match(CodeBase.regexp(CodeBase.all[5]))[1])
	assert_not_nil(CodeBase.gitStatus{|status,pathname| puts "status=#{status}, pathname=#{pathname}"})
	pathname='app/views/acquisition_stream_specs/_index_partial.html.erb'
	assert_not_empty(MatchedPathName.new(pathname).model_name.singular_model_name)
	CodeBase.why_not_stage(pathname,MatchedPathName.new(pathname).model_name.singular_model_name)
	CodeBase.gitStatus{|status,pathname| pathname}
	CodeBase.gitStatus{|status,pathname| MatchedPathName.new(pathname)}
#.gitignore	CodeBase.gitStatus{|status,pathname| MatchedPathName.new(pathname)}.each {|p| assert_not_nil(p[:spec], "p=#{p.inspect}")}
#	CodeBase.gitStatus{|status,pathname| MatchedPathName.new(pathname)[:spec][:plural]}
#	CodeBase.gitStatus{|status,pathname| MatchedPathName.new(pathname).model_name}
#	CodeBase.gitStatus{|status,pathname| MatchedPathName.new(pathname).model_name.singular_model_name }
#	CodeBase.gitStatus{|status,pathname| CodeBase.why_not_stage(pathname,MatchedPathName.new(pathname).model_name.singular_model_name) }
#	assert_nothing_raised{CodeBase.gitStatus{|status,pathname| CodeBase.why_not_stage(pathname,MatchedPathName.new(pathname).model_name.singular_model_name) }}
	assert_equal('global',MatchedPathName.new('test/unit/global_test.rb').model_name.singular_model_name)
	assert_include('app/views/acquisition_stream_specs/index.html.erb',CodeBase.controller_sources('acquisition_stream_spec'))
end #git_status
def test_git_add_successful
end #git_add_successful
def test_why_not_stage_helper
	pathname='app/views/acquisition_stream_specs/_index_partial.html.erb'
#	assert_nothing_raised{CodeBase.why_not_stage_helper('app/views/acquisition_stream_specs/_index_partial.html.erb',target,sources,test_type)}
end #why_not_stage_helper
def test_why_not_stage
	pathname='app/views/acquisition_stream_specs/_index_partial.html.erb'
#	assert_nothing_raised{CodeBase.why_not_stage_helper('app/views/acquisition_stream_specs/_index_partial.html.erb',target,sources,test_type)}
end #why_not_stage_helper
def test_rails_MVC_classes
	assert_include(StreamMethod,CodeBase.rails_MVC_classes)
	assert_not_include(Generic_Table,CodeBase.rails_MVC_classes)
	assert_not_include(CodeBase,CodeBase.rails_MVC_classes)
	assert_not_include(MethodModel,CodeBase.rails_MVC_classes)
end #rails_MVC_classes
def test_example_pathnames_exist
	CodeBase.all.each do |spec|
		example_pathname=spec[:example_pathname]
		assert(File.exists?(example_pathname))
		if !example_pathname.match(spec.regexp) then
			puts "#{example_pathname} not \n#{regexp.inspect}"
		else
			#~ puts "#{example_pathname} matches \n#{regexp.inspect}"
		end #if
	end #each_pair
end #example_pathnames_exist
def test_example_pathnames_match_regexp
	CodeBase.all.each do |spec|
		example_pathname=spec[:example_pathname]
		assert(example_pathname.match(spec.regexp))
	end #each_pair
	CodeBase.all.each do |spec|
		example_pathname=spec[:example_pathname]
		regexp=spec.regexp
		assert_match(regexp,example_pathname,"example_pathname=#{example_pathname}, regexp=#{regexp}")
	end #each
end #example_pathnames_match_regexp
def test_globs_match_regexp
	CodeBase.all.each do |spec|
		pathnames=Dir[spec.pathname_glob]
		if pathnames.nil? then
			raise "#{spec.pathname_glob} does not match any pathnames."
		end #if
		regexp=spec.regexp
		spec.pathnames.each do |pathname| # regexp matching pathnames
			assert_match(regexp,pathname,"pathname=#{pathname} matches fileglob=#{spec.pathname_glob} but not regexp=#{regexp}")
		end #each
	end #each

end #globs_match_regexp
end #CodeBase
class MatchedPathNameTest < TestCase
require_relative '../../lib/tasks/testing.rb'
@@Test_pathname='app/models/code_base.rb'
def test_MatchedPathName
	matched_path_name=MatchedPathName.new(@@Test_pathname)
	assert_instance_of(CodeBase,matched_path_name[:spec])
	assert_equal(@@Test_pathname,matched_path_name[:pathname])
	assert_equal(@@Test_pathname,matched_path_name['pathname'])
	assert_equal(@@Test_pathname,matched_path_name[:matchData][0])
	assert_equal(:models,matched_path_name[:spec][:name])
	assert_instance_of(MatchedPathName,matched_path_name)

	assert_attribute_of(matched_path_name, :pathname, String)
	assert_attribute_of(matched_path_name, :matchData, MatchData)
	assert_attribute_of(matched_path_name[:spec], :name, Symbol)
	assert_attribute_of(MatchedPathName.new(@@Test_pathname), :spec, CodeBase)
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
def test_ssert_no_attributes
end #assert_no_attributes
def test_assert_has_attributes
end #assert_has_attributes
def test_all
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
	assert_instance_of(MatchedPathName,matched_path_name)
	assert_not_nil(matched_path_name)
	test_runs=matched_path_name.suggest_test_runs
	assert_not_empty(test_runs)
end #suggest_test_runs
def test_test_schedule
end #test_schedule
def schedule_tests
end #schedule_tests
def test_matched_model_name
	matched_path_name=MatchedPathName.new(@@Test_pathname)
	assert_equal('code_base', matched_path_name.matched_model_name)
end #matched_model_name
def test_matched_model_name_plurality
	matched_path_name=MatchedPathName.new(@@Test_pathname)
	assert_equal(false, matched_path_name.matched_model_name_plurality)
end #matched_model_name_plurality
def test_model_name
	matched_path_name=MatchedPathName.new(@@Test_pathname)
	assert_equal('code_base', matched_path_name.model_name.singular_model_name)
	assert_equal('code_bases', matched_path_name.model_name.plural_model_name)
end #model_name
def test_test_name
end #test_name
end #MatchedPathName
class ModelNameTest < TestCase
@@Test_pathname='app/models/code_base.rb'
def test_ModelNames
	assert_equal('code_base', ModelName.new('code_base', false).singular_model_name)
	assert_equal('code_bases', ModelName.new('code_bases', true)[:plural_model_name])
	assert_equal('code_bases', ModelName.new('code_bases', true).plural_model_name)
	assert_equal('code_bases', ModelName.new(MatchedPathName.new(@@Test_pathname), true).plural_model_name)
	
end #initialize
def test_ModelName_all
	controller_spec=CodeBase.find_by_name(:controllers)
	controller_pathnames=controller_spec.pathnames
	assert_not_empty(controller_pathnames)
#	pattern='(\w+)\.all'
	pattern='(\w+)all'
	regexp=Regexp.new(pattern)
	delimiter="\n"
	grep_matches=Generic_Table.grep(controller_pathnames, pattern, delimiter).map do |h|
		model_name=ModelName.new(h[:match].tableize, :singular)
		model_name[:plural_model_name]=h[:pathname]
	end #map
	assert_instance_of(Array, grep_matches)
	assert_equal([], grep_matches)
	assert_instance_of(Array, ModelName.all)
	assert_equal([], ModelName.all)

end #ModelName_all
def test_singular_model_name
	assert_equal('test_run', ModelName.new('test_runs', true).singular_model_name)
	assert_equal('code_bases', ModelName.new('code_base', false).plural_model_name)
	assert_equal('code_base', ModelName.new('code_bases', true).singular_model_name)
	matched_path_name=MatchedPathName.new(@@Test_pathname)
	assert_equal('code_base',ModelName.new(matched_path_name).singular_model_name)

end #singular_model_name
def test_plural_model_name
	assert_equal('code_bases', ModelName.new('code_base', false).plural_model_name)
	matched_path_name=MatchedPathName.new(@@Test_pathname)
	assert_equal('code_bases',ModelName.new(matched_path_name).plural_model_name)
end #plural_model_name
def test_find_model_name
end #find_model_name
def test_grep_controller_scaffold_variables
	plural_model_name='urls'
	spec=CodeBase.find_by_name(:controllers)
	controller_pathnames=spec.pathnames
	file_regexp='app/controllers/urls_controller.rb'
	pattern='(\w+)\.all'
	regexp=Regexp.new(pattern)
	delimiter="\n"

	model_name=ModelName.new(plural_model_name, true)
	assert_equal([{:match => 'Url'}], Generic_Table.grep("([A-Za-z0-9_]+)\.all", spec.regexp))

	ps=RegexpTree.new(file_regexp).pathnames
	p=ps.first
	assert_equal([p], ps)
	assert_instance_of(String, p)
	l=IO.read(p).split(delimiter).first
	assert_instance_of(String, l)
	matchData=regexp.match(l)
	assert_instance_of(Hash, {:pathname => p, :match => 'Url'})
	if matchData then
		assert_instance_of(Hash, {:pathname => p, :match => matchData[1]})
	end #if
	grep_matches=Generic_Table.grep(file_regexp, pattern)
	assert_instance_of(Array, grep_matches)
	assert_equal([{:match=>"Url", :pathname=>"app/controllers/urls_controller.rb"}], grep_matches)
	assert_instance_of(Hash, grep_matches[0])
	assert_equal(file_regexp, grep_matches[0][:pathname])
	assert_equal('Url', grep_matches[0][:match])
end #grep_controller_scaffold_variables
end #ModelName
