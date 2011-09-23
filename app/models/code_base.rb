class CodeBase
# [name, example_file, Dir_glob, plural,test_type]
TABLE_FINDER_REGEXPS=[
{:name => :models, :example_file => 'app/models/global.rb', :Dir_glob =>  'app/models/([a-zA-Z0-9_]*)[.]rb', :plural => false, :test_type => :both},
{:name => :unit_tests, :example_file => 'test/unit/global_test.rb', :Dir_glob =>  'test/unit/([a-zA-Z0-9_]*)_test[.]rb', :plural => false, :test_type => :unit},
{:name => :functional_tests, :example_file => 'test/functional/stream_patterns_controller_test.rb', :Dir_glob =>  'test/functional/([a-zA-Z0-9_]*)_controller_test[.]rb', :plural => true, :test_type => :controller},
{:name => :unit_test_logs, :example_file => 'log/unit/generic_table_test.log', :Dir_glob =>  'log/unit/([a-zA-Z0-9_]*)_test[.]log', :plural => false, :test_type => :unit},
{:name => :functional_test_logs, :example_file => 'log/functional/stream_patterns_controller_test.log', :Dir_glob =>  'log/functional/([a-zA-Z0-9_]*)_controller_test[.]log', :plural => true, :test_type => :controller},
{:name => :new_views, :example_file => 'app/views/acquisition_stream_specs/new.html.erb', :Dir_glob =>  'app/views/([a-z_]*)/new[.]html[.]erb', :plural => true, :test_type => :controller},
{:name => :edit_views, :example_file => 'app/views/acquisition_stream_specs/edit.html.erb', :Dir_glob =>  'app/views/([a-z_]*)/edit[.]html[.]erb', :plural => true, :test_type => :controller},
{:name => :show_views, :example_file => 'app/views/acquisition_stream_specs/show.html.erb', :Dir_glob =>  'app/views/([a-z_]*)/show[.]html[.]erb', :plural => true, :test_type => :controller},
{:name => :index_views, :example_file => 'app/views/acquisition_stream_specs/index.html.erb', :Dir_glob =>  'app/views/([a-z_]*)/index[.]html[.]erb', :plural => true, :test_type => :controller},
{:name => :shared_partials, :example_file => 'app/views/shared/_multi-line.html.erb', :Dir_glob =>  'app/views/shared/_[a-zA-Z0-9_-]*[.]html[.]erb', :plural => true, :test_type => :shared},
{:name => :form_partials, :example_file => 'app/views/stream_patterns/_form.html.erb', :Dir_glob =>  'app/views/([a-z_]*)/_form[.]html[.]erb', :plural => true, :test_type => :controller},
{:name => :show_partials, :example_file => 'app/views/stream_patterns/_show_partial.html.erb', :Dir_glob =>  'app/views/([a-z_]*)/_show_partial[.]html[.]erb', :plural => true, :test_type => :controller},
{:name => :index_partials, :example_file => 'app/views/stream_patterns/_index_partial.html.erb', :Dir_glob =>  'app/views/([a-z_]*)/_index_partial[.]html[.]erb', :plural => true, :test_type => :controller}
]
def initialize(hash)
	@spec=hash
end #initialize
def CodeBase.file_glob(spec)
	ret=spec[:Dir_glob].sub(/(\()/,'').sub(/(\))/,'')
	return ret
end #file_glob
def CodeBase.regexp(spec)
	ret='^'+spec[:Dir_glob]+'$'
	return Regexp.new(ret)
end #regexp
def files_from_spec
	Dir[CodeBase.file_glob(@spec)]
end #files_from_spec
def CodeBase.all_model_specfic_files
	TABLE_FINDER_REGEXPS.map  do |hash|
		CodeBase.new(hash).files_from_spec.map do |file|
			{ :file => file, :spec => hash }
		end #map
	end.flatten #map
end #all_model_specfic_files
ALL_TEST_FILES=CodeBase.all_model_specfic_files
#	puts "ALL_TEST_FILES=#{ALL_TEST_FILES.inspect}"
FILE_MOD_TIMES=ALL_TEST_FILES.map { |file_and_spec| { :file => file_and_spec[:file],:mtime => File.mtime(file_and_spec[:file]), :spec => file_and_spec[:spec]}}.sort! {|x,y| y[:mtime] <=> x[:mtime] } # sort on file mod times

AFFECTS_EVERYTHING=["db/schema.rb","test/test_helper.rb",'app/models/global.rb','app/models/generic_table.rb']
AFFECTS_CONTROLLERS=Dir['app/views/shared/*']



def CodeBase.prioritized_file_order(&process_test)
	file_type_pairs=CodeBase::FILE_MOD_TIMES.map do |file_and_spec|
		singular_table=singular_table_from_file(file_and_spec[:file])
		test_type=file_and_spec[:spec][:test_type].to_s
		[singular_table,test_type]
	end #map
	file_type_pairs.each do |file_and_type|
		singular_table=file_and_type[0]
		case file_and_type[1].to_sym
		when :unit
			process_test.call(CodeBase.unit_target(singular_table), CodeBase.unit_sources(singular_table))
		when :controller
			process_test.call(CodeBase.controller_target(singular_table), CodeBase.controller_sources(singular_table))
		when :both
			process_test.call(CodeBase.unit_target(singular_table), CodeBase.unit_sources(singular_table)) &&
			process_test.call(CodeBase.controller_target(singular_table), CodeBase.controller_sources(singular_table))
		when :shared
			# some other file will trigger compilation
		else
			raise "illegal test type=#{test_type}"
		end #case
	end #each
end #prioritized_file_order
def CodeBase.run_test(singular_table, test_type)
	case test_type
	when :unit
		TestRun.ruby_run_and_log(test_file(singular_table, test_type),unit_target(singular_table))
	when :controller
		TestRun.ruby_run_and_log(test_file(singular_table, test_type),controller_target(singular_table))

	else raise "Unnown test_type=#{test_type} for singular_table=#{singular_table}"
	end #case
end #run_test
def CodeBase.not_uptodate_order(&proc_update)
	CodeBase.prioritized_file_order do |target,sources|
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
	end #prioritized_file_order
end #not_uptodate_order

def CodeBase.test_file(singular_table, test_type)
	case test_type.to_sym
	when :unit
		return "test/unit/#{singular_table}_test.rb"
	when :controller
		return "test/functional/#{plural_table}_controller_test.rb"
	else raise "Unnown test_type=#{test_type} for singular_table=#{singular_table}"
	end #case
end #test_file
def CodeBase.model_file(singular_table)
	return "app/models/#{singular_table}.rb"
end #model_file
def CodeBase.unit_sources(singular_table)
	plural_table=singular_table.pluralize
	# commn_sources apply to both unit and functional tests.
	model_file="app/models/#{singular_table}.rb"
	common_sources=AFFECTS_EVERYTHING+[model_file,"test/fixtures/#{plural_table}.yml"]
	return ["test/unit/#{singular_table}_test.rb"]+common_sources
end #unit_sources
def CodeBase.controller_sources(singular_table)
	plural_table=singular_table.pluralize
	# commn_sources apply to both unit and functional tests.
	common_sources=AFFECTS_EVERYTHING+[model_file(singular_table),"test/fixtures/#{plural_table}.yml"]
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
	return CodeBase::TABLE_FINDER_REGEXPS.select {|s| s[:test_type]!=:shared}.map {|s| s[:name]}
end #model_spec_symbols
def CodeBase.spec_symbols
	return CodeBase::TABLE_FINDER_REGEXPS.map {|s| s[:name]}
end #spec_symbols
def CodeBase.complete_models
	list_of_model_sets=CodeBase.model_spec_symbols.map {|spec_name_symbol| CodeBase.models_from_spec(spec_name_symbol)}
	list_of_model_sets.reduce(:&)
end #complete_models
def CodeBase.spec_from_symbol(spec_name_symbol)
	index=CodeBase::TABLE_FINDER_REGEXPS.index {|s| s[:name]==spec_name_symbol.to_sym}
	raise "spec_name_symbol=#{spec_name_symbol} not found" if index.nil?
	return CodeBase::TABLE_FINDER_REGEXPS[index]
end #spec_from_symbol
def CodeBase.models_from_spec(spec_name_symbol)
	spec=spec_from_symbol(spec_name_symbol)
	raise "models_from_spec called with spec=#{spec.inspect}" if spec[:test_type]==:shared
	files=Dir[CodeBase.file_glob(spec)]
	if files.nil? then
		raise "#{CodeBase.file_glob(spec)} does not match any files."
	end #if
	models=files.map do|f|
		model=f[CodeBase.regexp(spec),1]
		if model.nil? then
			raise "file=#{f} does not match regexp=#{CodeBase.regexp(spec)}"
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
def CodeBase.match_spec_from_file(file)
	TABLE_FINDER_REGEXPS.each do |match_specs|
		matchData=file.match(match_specs[:Dir_glob])
		if matchData then
			match_specs[:matchData]=matchData # add match data found
			return match_specs
		end #if
	end #each
	return nil # if no match
end #match_spec_from_file
def CodeBase.singular_table_from_file(file)
	match_spec=match_spec_from_file(file)
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
end #singular_table_from_file
def CodeBase.name_plurality_from_spec(match_spec)
	if match_spec.nil? || match_spec[:test_type]==:shared then
		return  nil
	else
		table_name=match_spec[:matchData][1]
		if match_spec[:plural] then
			{:singular => table_name.singularize, :plural => table_name}
		else
			{:singular =>  table_name, plural => table_name.pluralize}
		end #if
	end #if
end #test_run_from_file
def CodeBase.test_run_from_file(file)
	match_spec=match_spec_from_file(file)
	name_plurality=name_plurality_from_spec(match_spec)
	TestRun.new(match_spec[:test_type],name_plurality[:singular], name_plurality[:plural])
end #test_run_from_file
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
def CodeBase.test_program_from_file(ruby_source)
#	singular_table=CodeBase.singular_table_from_file(ruby_source)
	test_type=test_type_from_source(ruby_source)
	return CodeBase.test_file(test_type[0], test_type[1])
end #test_program_from_file
def CodeBase.uptodate?(target,sources) 
	raise "sources=#{sources.inspect} must be an Array of Strings(pathnames)" unless sources.instance_of?(Array)
	raise "target=#{target.inspect} must be a String (pathnames)" unless target.instance_of?(String)
	sources.each do |s|
		#~ system ("ls -l #{target}") {|ok, res| } # discard result if file doesn't exist
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
# determine which files should be staged if test is successful
# all files newer than previous test log.
# file must also have changed since last staging
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
		status,file=line.split(" ")
		process_status.call(status,file)
	end #each
end #gitStatus
def CodeBase.git_add_successful(not_uptodate_sources)
	not_uptodate_sources.each do |s|
		sh "git add #{s}"
	end #each

end #def

# stage target and source files when all tests pass.
# stage model file and .yml files when BOTH unit and controller tests pass
def CodeBase.why_not_stage_helper(file,target,sources,test_type)
	if File.exists?(target) then
		#~ puts "Target #{target}  does exist." 
		if TestRun.log_passed?(target) then
			system "git add #{target}"
			if file==target then
				return true
			elsif  uptodate?(target,[file]) then
				if sources.include?(file) then
					system "git add #{file}"
					return true
				else
					puts "#{file} not a #{test_type} source."
					return false
				end #if
			else
				puts "#{file} not up to date." 
			end #if
			return true
		else
			return false
		end #if
	else
		puts "Target #{target} for file=#{file} does not exist."
		return false
	end #if

end #why_not_stage_helper
# stage target and source files when all tests pass.
# stage model file and .yml files when BOTH unit and controller tests pass
def CodeBase.why_not_stage(file,singular_table)
	match_spec=match_spec_from_file(file)
	if match_spec.nil? then
		singular_table=FILE_MOD_TIMES[FILE_MOD_TIMES.size/2][0] # pick average file, not too active, not too abandoned
		puts "#{file} don't know when to stage."
	else
		singular_table=singular_table_from_file(file)
		why_not_stage_helper(file,unit_target(singular_table),unit_sources(singular_table),:unit)  if match_spec[:test_type] != :controller
		if File.exists?(controller_target(singular_table)) then
			why_not_stage_helper(file,controller_target(singular_table),controller_sources(singular_table),:controller)  if match_spec[:test_type] != :unit
		end #if
	end #if
end #example_files_exist
end #class CodeBase
