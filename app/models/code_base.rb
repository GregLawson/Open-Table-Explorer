###########################################################################
#    Copyright (C) 2011 by Greg Lawson                                      
#    <GregLawson@gmail.com>                                                             
#
# Copyright: See COPYING pathname that comes with this distribution
#
###########################################################################
class CodeBase
include NoDB
# [name, example_pathname, Dir_glob, plural,test_type]
@@TABLE_FINDER_REGEXPS=[
{:name => :models, :example_pathname => 'app/models/global.rb', :Dir_glob =>  'app/models/([a-zA-Z0-9_]*)[.]rb', :plural => false, :test_type => :both},
{:name => :unit_tests, :example_pathname => 'test/unit/global_test.rb', :Dir_glob =>  'test/unit/([a-zA-Z0-9_]*)_test[.]rb', :plural => false, :test_type => :unit},
{:name => :functional_tests, :example_pathname => 'test/functional/stream_patterns_controller_test.rb', :Dir_glob =>  'test/functional/([a-zA-Z0-9_]*)_controller_test[.]rb', :plural => true, :test_type => :controller},
{:name => :unit_test_logs, :example_pathname => 'log/unit/generic_table_test.log', :Dir_glob =>  'log/unit/([a-zA-Z0-9_]*)_test[.]log', :plural => false, :test_type => :unit},
{:name => :functional_test_logs, :example_pathname => 'log/functional/stream_patterns_controller_test.log', :Dir_glob =>  'log/functional/([a-zA-Z0-9_]*)_controller_test[.]log', :plural => true, :test_type => :controller},
{:name => :new_views, :example_pathname => 'app/views/acquisition_stream_specs/new.html.erb', :Dir_glob =>  'app/views/([a-z_]*)/new[.]html[.]erb', :plural => true, :test_type => :controller},
{:name => :edit_views, :example_pathname => 'app/views/acquisition_stream_specs/edit.html.erb', :Dir_glob =>  'app/views/([a-z_]*)/edit[.]html[.]erb', :plural => true, :test_type => :controller},
{:name => :show_views, :example_pathname => 'app/views/acquisition_stream_specs/show.html.erb', :Dir_glob =>  'app/views/([a-z_]*)/show[.]html[.]erb', :plural => true, :test_type => :controller},
{:name => :index_views, :example_pathname => 'app/views/acquisition_stream_specs/index.html.erb', :Dir_glob =>  'app/views/([a-z_]*)/index[.]html[.]erb', :plural => true, :test_type => :controller},
{:name => :shared_partials, :example_pathname => 'app/views/shared/_multi-line.html.erb', :Dir_glob =>  'app/views/shared/_[a-zA-Z0-9_-]*[.]html[.]erb', :plural => true, :test_type => :controller},
{:name => :form_partials, :example_pathname => 'app/views/stream_patterns/_form.html.erb', :Dir_glob =>  'app/views/([a-z_]*)/_form[.]html[.]erb', :plural => true, :test_type => :controller},
{:name => :show_partials, :example_pathname => 'app/views/stream_patterns/_show_partial.html.erb', :Dir_glob =>  'app/views/([a-z_]*)/_show_partial[.]html[.]erb', :plural => true, :test_type => :controller},
{:name => :index_partials, :example_pathname => 'app/views/stream_patterns/_index_partial.html.erb', :Dir_glob =>  'app/views/([a-z_]*)/_index_partial[.]html[.]erb', :plural => true, :test_type => :controller}
]
# Initializes a spec from a hash
def initialize(hash=nil)
	super
end #initialize
# Returns all specs
def CodeBase.all
	return @@TABLE_FINDER_REGEXPS.map {|spec| CodeBase.new(spec)}
end #all
# Returns a file glob to find pathname, removing parenthesis
def pathname_glob
	ret=self[:Dir_glob].sub(/(\()/,'').sub(/(\))/,'')
	return ret
end #pathname_glob
# Returns a Regexp to extract model names from pathname, keeping parenthesis
def regexp
	ret='^'+self[:Dir_glob]+'$'
	return Regexp.new(ret)
end #regexp
# Find array of pathnames that match CodeBase spec
def pathnames_from_spec
	Dir[pathname_glob]
end #pathnames_from_spec
def []=(name, attribute)
	self[name]=attribute.class.new(attribute)
end #[]=
AFFECTS_EVERYTHING=["db/schema.rb","test/test_helper.rb",'app/models/global.rb','app/models/generic_table.rb']
AFFECTS_CONTROLLERS=Dir['app/views/shared/*']
# priorities:
# most recent modification time from prioritized_pathname_order
# first test previously passed
# short test run time
def CodeBase.prioritized_pathname_order(&process_test)
	MatchedPathName.all.each do |matched_path_name|
		singular_table=matched_path_name[0]
		case matched_path_name[1].to_sym
		when :unit
			process_test.call(CodeBase.unit_target(singular_table), CodeBase.unit_sources(singular_table))
		when :controller
			process_test.call(CodeBase.controller_target(singular_table), CodeBase.controller_sources(singular_table))
		when :both
			process_test.call(CodeBase.unit_target(singular_table), CodeBase.unit_sources(singular_table)) &&
			process_test.call(CodeBase.controller_target(singular_table), CodeBase.controller_sources(singular_table))
		when :shared
			# some other pathname will trigger compilation
		else
			raise "illegal test type=#{test_type}"
		end #case
	end #each
end #prioritized_pathname_order
def CodeBase.run_test(singular_table, test_type)
	case test_type
	when :unit
		TestRun.ruby_run_and_log(test_pathname(singular_table, test_type),unit_target(singular_table))
	when :controller
		TestRun.ruby_run_and_log(test_pathname(singular_table, test_type),controller_target(singular_table))

	else raise "Unnown test_type=#{test_type} for singular_table=#{singular_table}"
	end #case
end #run_test
def CodeBase.not_uptodate_order(&proc_update)
	CodeBase.prioritized_pathname_order do |target,sources|
		raise "sources=#{sources.inspect} must be an Array of Strings(pathnames)" unless sources.instance_of?(Array)
		raise "target=#{target.inspect} must be a Strings(pathnames)" unless target.instance_of?(String)
		if CodeBase.uptodate?(target,sources) then
		else
			if !File.exist?(target) then
				proc_update.call(target,[])
			else
				not_uptodate_sources=CodeBase.not_uptodate_sources(target,sources)
				proc_update.call(target,not_uptodate_sources)
			end #if
		end #if
	end #prioritized_pathname_order
end #not_uptodate_order

def CodeBase.test_pathname(singular_table, test_type)
	case test_type.to_sym
	when :unit
		return "test/unit/#{singular_table}_test.rb"
	when :controller
		return "test/functional/#{plural_table}_controller_test.rb"
	else raise "Unnown test_type=#{test_type} for singular_table=#{singular_table}"
	end #case
end #test_pathname
def CodeBase.model_pathname(singular_table)
	return "app/models/#{singular_table}.rb"
end #model_pathname
def CodeBase.unit_sources(singular_table)
	plural_table=singular_table.pluralize
	# commn_sources apply to both unit and functional tests.
	model_pathname="app/models/#{singular_table}.rb"
	common_sources=AFFECTS_EVERYTHING+[model_pathname,"test/fixtures/#{plural_table}.yml"]
	return ["test/unit/#{singular_table}_test.rb"]+common_sources
end #unit_sources
def CodeBase.controller_sources(singular_table)
	plural_table=singular_table.pluralize
	# commn_sources apply to both unit and functional tests.
	common_sources=AFFECTS_EVERYTHING+[model_pathname(singular_table),"test/fixtures/#{plural_table}.yml"]
	sources=common_sources+Dir["app/views/#{plural_table}/*.html.erb"]+AFFECTS_CONTROLLERS
	return ["test/functional/#{plural_table}_controller_test.rb"] +sources+["app/controllers/#{plural_table}_controller.rb","app/helpers/#{plural_table}_helper.rb"]
end #controller_sources
def CodeBase.unit_target(singular_table)
	return "log/unit/#{singular_table}_test.log"
end #unit_target
def CodeBase.controller_target(singular_table)
	plural_table=singular_table.pluralize
	return "log/functional/#{plural_table}_controller_test.log"
end #controller_target
def CodeBase.model_spec_symbols
	return CodeBase.all.select {|s| s[:test_type]!=:shared}.map {|s| s[:name]}
end #model_spec_symbols
def CodeBase.spec_symbols
	return CodeBase.all.map {|s| s[:name]}
end #spec_symbols
def CodeBase.complete_models
	list_of_model_sets=CodeBase.model_spec_symbols.map {|spec_name_symbol| CodeBase.models_from_spec(spec_name_symbol)}
	list_of_model_sets.reduce(:&)
end #complete_models
def CodeBase.spec_from_symbol(spec_name_symbol)
	index=CodeBase.all.index {|s| s[:name]==spec_name_symbol.to_sym}
	raise "spec_name_symbol=#{spec_name_symbol} not found" if index.nil?
	return CodeBase.all[index]
end #spec_from_symbol
def CodeBase.models_from_spec(spec_name_symbol)
	spec=spec_from_symbol(spec_name_symbol)
	raise "models_from_spec called with spec=#{spec.inspect}" if spec[:test_type]==:shared
	pathnames=Dir[CodeBase.pathname_glob(spec)]
	if pathnames.nil? then
		raise "#{CodeBase.pathname_glob(spec)} does not match any pathnames."
	end #if
	models=pathnames.map do|f|
		model=f[CodeBase.regexp(spec),1]
		if model.nil? then
			raise "pathname=#{f} does not match regexp=#{CodeBase.regexp(spec)}"
		end #if
		if spec[:plural] then
			model=model.singularize
		end #if
		model
	end #map
	if models.instance_of?(Array) then
		return Set.new(models)
	else
		return Set[]
	end #if
end #models_from_spec
def CodeBase.match_spec_from_pathname(pathname)
	CodeBase.all.each do |match_specs|
		matchData=pathname.match(match_specs[:Dir_glob])
		if matchData then
			match_specs[:matchData]=matchData # add match data found
			return match_specs
		end #if
	end #each
	return nil # if no match
end #match_spec_from_pathname
def CodeBase.singular_table_from_pathname(pathname)
	match_spec=match_spec_from_pathname(pathname)
	if match_spec.nil? || match_spec[:test_type]==:shared then
		return  ''
	else
		table_name=match_spec[:matchData][1]
		if match_spec[:plural] then
			return table_name.singularize
		else
			return table_name
		end #if
	end #if
end #singular_table_from_pathname
def CodeBase.test_run_from_pathname(pathname)
	match_spec=match_spec_from_pathname(pathname)
	name_plurality=name_plurality(match_spec)
	TestRun.new(match_spec[:test_type],name_plurality[:singular], name_plurality[:plural])
end #test_run_from_pathname
def CodeBase.test_type_from_source(ruby_source)
	path=Pathname.new(ruby_source)
	#~ puts "path=#{path.inspect}"
	words=path.basename.to_s.split('_')
#	puts "words=#{words.inspect}"
	raise "not a test log or source pathname =#{path.inspect}" if words[-1][0..3]!='test'
	if words[-2]=='controller' then
		test_type='functional'
		table=words[0..-3].join('_')
	else
		test_type='unit'
		table=words[0..-2].join('_')
	end #if
	#~ puts "test_type='#{test_type}'"
	return [table,test_type]
end #test_type_from_source
def CodeBase.test_program_from_pathname(ruby_source)
#	singular_table=CodeBase.singular_table_from_pathname(ruby_source)
	test_type=test_type_from_source(ruby_source)
	return CodeBase.test_pathname(test_type[0], test_type[1])
end #test_program_from_pathname
def CodeBase.uptodate?(target,sources) 
	raise "sources=#{sources.inspect} must be an Array of Strings(pathnames)" unless sources.instance_of?(Array)
	raise "target=#{target.inspect} must be a String (pathnames)" unless target.instance_of?(String)
	sources.each do |s|
		#~ system ("ls -l #{target}") {|ok, res| } # discard result if pathname doesn't exist
		#~ system "ls -l #{s}"
		if !File.exist?(target) then
			return false
		end #def
		if !File.exist?(s) then
			return false
		end #def
		if File.mtime(target)<File.mtime(s) then
			return false
		end #if
	end #each
	return true
end #uptodate
# determine which pathnames should be staged if test is successful
# all pathnames newer than previous test log.
# pathname must also have changed since last staging
def CodeBase.not_uptodate_sources(target,sources)
	raise "sources=#{sources.inspect} must be an Array" unless sources.instance_of?(Array)
	puts "sources=#{sources.inspect} must be an Array of Strings(pathnames)"
	puts "sources.size=#{sources.size} "
	puts "sources[0]=#{sources[0].inspect} "
	sources.each do |p|
		puts "p=#{p.inspect} must be a String(pathnames)" unless p.instance_of?(String)
	end #each
	raise "sources=#{sources.inspect} must be an Array of Strings(pathnames)" unless sources.any?{|s| s.instance_of?(String)}
	raise "target=#{target.inspect} must be a String (pathnames)" unless target.instance_of?(String)
	sources.select {|s| !File.exist?(target) ||  File.exist?(s) && !uptodate?(target, [s])}
end #not_uptodate_sources
def CodeBase.gitStatus(&process_status)
	return `git status --porcelain`.split("\n").each do |line| 
		status,pathname=line.split(" ")
		process_status.call(status,pathname)
	end #each
end #gitStatus
def CodeBase.git_add_successful(not_uptodate_sources)
	not_uptodate_sources.each do |s|
		sh "git add #{s}"
	end #each

end #def

# stage target and source pathnames when all tests pass.
# stage model pathname and .yml pathnames when BOTH unit and controller tests pass
def CodeBase.why_not_stage_helper(pathname,target,sources,test_type)
	if File.exists?(target) then
		#~ puts "Target #{target}  does exist." 
		if TestRun.log_passed?(target) then
			system "git add #{target}"
			if pathname==target then
				return true
			elsif  uptodate?(target,[pathname]) then
				if sources.include?(pathname) then
					system "git add #{pathname}"
					return true
				else
					puts "#{pathname} not a #{test_type} source."
					return false
				end #if
			else
				puts "#{pathname} not up to date." 
			end #if
			return true
		else
			return false
		end #if
	else
		puts "Target #{target} for pathname=#{pathname} does not exist."
		return false
	end #if

end #why_not_stage_helper
# stage target and source pathnames when all tests pass.
# stage model pathname and .yml pathnames when BOTH unit and controller tests pass
def CodeBase.why_not_stage(pathname,singular_table)
	match_spec=match_spec_from_pathname(pathname)
	if match_spec.nil? then
		singular_table=FILE_MOD_TIMES[FILE_MOD_TIMES.size/2][0] # pick average pathname, not too active, not too abandoned
		puts "#{pathname} don't know when to stage."
	else
		singular_table=singular_table_from_pathname(pathname)
		why_not_stage_helper(pathname,unit_target(singular_table),unit_sources(singular_table),:unit)  if match_spec[:test_type] != :controller
		if File.exists?(controller_target(singular_table)) then
			why_not_stage_helper(pathname,controller_target(singular_table),controller_sources(singular_table),:controller)  if match_spec[:test_type] != :unit
		end #if
	end #if
end #example_pathnames_exist
@@ALL_VIEW_DIRS||=Dir['app/views/*']
def CodeBase.rails_MVC_classes
#	puts fixture_names.inspect
	@@ALL_VIEW_DIRS.map do |view_dir|
		model_pathnamename=view_dir.sub(%r{^app/views/},'')
		if Generic_Table.is_generic_table_name?(model_pathnamename.singularize) then
			model_pathnamename.classify.constantize
		else
#			puts "File.exists?(\"app/models/#{model_pathnamename}\")=#{File.exists?('app/models/'+model_pathnamename)}"
			nil # discarded by later Array#compact
		end #if
	end.compact #map
end #rails_MVC_classes
end #class CodeBase
class MatchedPathName
include NoDB
def initialize(pathname, specified_spec=nil)
	super()
	self[:pathname]=pathname
	self[:mtime] = File.mtime(pathname)
	if specified_spec.nil? then
		CodeBase.all.each do |spec|
			matchData=pathname.match(spec[:Dir_glob])
			if matchData then
				self[:matchData]=matchData # add match data found
				self[:spec]=spec
				return self
			end #if
		end #each
		self[:spec]=nil # not matched
	else
		self[:spec]=specified_spec
	end #if
	self[:matchData]=nil # not matched
end #initialize MatchedPathName
def assert_no_attributes(obj)
	assert_equal(0, obj.size)
end #
def assert_has_attributes(obj)
	assert_not_equal(0, obj.size)
end #assert_has_attributes
# Returns all matched files.
# Candidates for new test run (including shared files)
# Called by all_tests
def MatchedPathName.all
	CodeBase.all.map  do |spec|
		spec.pathnames_from_spec.map do |pathname|
			MatchedPathName.new(pathname, spec)
		end #map
	end.flatten.sort! {|x,y| y[:mtime] <=> x[:mtime] } #map
end #all
# called by suggest_test_runs for ambiguous (shared)
FILE_MOD_TIMES=MatchedPathName.all.map { |pathname_and_spec| { :pathname => pathname_and_spec[:pathname],:mtime => File.mtime(pathname_and_spec[:pathname]), :spec => pathname_and_spec[:spec]}}.sort! {|x,y| y[:mtime] <=> x[:mtime] } # sort on pathname mod times
def MatchedPathName.all_tests(test_type)
	test_matches= all.select {|match| match[:test_type]=test_type}
	ret=test_matches.map {|m| m.suggest_test_runs}.flatten
	return ret
end #all_tests
# Returns TestRun or array of TestRuns for ambiguous
# Suggest test order to run after file modified
def suggest_test_runs
	name_plurality=self[:spec].name_plurality
	test_type=self[:spec][:test_type].to_sym
	if self[:matchData].nil? then
		all_tests=MatchedPathName.all_tests(test_type)
	else
	case self[:spec][:test_type].to_sym
	when :unit
			TestRun.new(:unit,name_plurality[:singular], name_plurality[:plural])
	when :controller
		TestRun.new(:controller,name_plurality[:singular], name_plurality[:plural])
	when :both
		[TestRun.new(:unit,name_plurality[:singular], name_plurality[:plural]),
		TestRun.new(:controller,name_plurality[:singular], name_plurality[:plural])]
	else
		raise "bad test_type=#{test_type}"
	end #case
	end #if
end #suggest_test_runs
def MatchedPathName.test_schedule
	MatchedPathName.all.suggest_test_runs.each do |candidate| 
		if candidate.instance_of?(Array) then
			ret=candidate.first{|tr| tr.up_to_date?}
		else
			!candidate.up_to_date?
		end #if
	end #
end #test_schedule
def MatchedPathName.schedule_tests
	MatchedPathName.test_schedule.each do |tr|
		if !tr.up_to_date? then #test updated earlier in this iteration
			tr.run
		end #if
	end #each
end #schedule_tests
def name_plurality
	if self.nil? || self[:test_type]==:shared then
		return  nil
	else
		table_name=self[:matchData][1]
		if self[:plural] then
			{:singular => table_name.singularize, :plural => table_name}
		else
			{:singular =>  table_name, :plural => table_name.pluralize}
		end #if
	end #if
end #name_plurality
end #MatchedPathName