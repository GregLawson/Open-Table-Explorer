module CodeBase
# [example_file, Dir_glob, plural,test_type]
TABLE_FINDER_REGEXPS=[
{:example_file => 'app/models/global.rb', :Dir_glob =>  'app/models/([a-zA-Z0-9_]*)[.]rb', :plural => false, :test_type => :both},
{:example_file => 'test/unit/global_test.rb', :Dir_glob =>  'test/unit/([a-zA-Z0-9_]*)_test[.]rb', :plural => false, :test_type => :unit},
{:example_file => 'test/functional/stream_patterns_controller_test.rb', :Dir_glob =>  'test/functional/([a-zA-Z0-9_]*)_test[.]rb', :plural => true, :test_type => :controller},
{:example_file => 'log/unit/generic_table_test.log', :Dir_glob =>  'log/unit/([a-zA-Z0-9_]*)_test[.]log', :plural => false, :test_type => :unit},
{:example_file => 'log/functional/stream_patterns_controller_test.log', :Dir_glob =>  'log/functional/([a-zA-Z0-9_]*)_controller_test[.]log', :plural => true, :test_type => :controller},
{:example_file => 'app/views/acquisition_stream_specs/_index_partial.html.erb', :Dir_glob =>  'app/views/([a-z_]*)/[a-zA-Z0-9_]*[.]html[.]erb', :plural => true, :test_type => :controller}
]
def CodeBase.match_spec_from_file(file)
	TABLE_FINDER_REGEXPS.each do |match_specs|
		matchData=file.match(match_specs[:Dir_glob])
		if matchData then
			match_specs[:matchData]=matchData # add match data found
			return match_specs
		end #if
	end #each
	return nil # if no match
end #def
def CodeBase.singular_table_from_file(file)
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
def CodeBase.file_glob(spec)
	ret=spec[:Dir_glob].sub(/(\()/,'').sub(/(\))/,'')
	return ret
end #def
def CodeBase.regexp(spec)
	ret='^'+spec[:Dir_glob]+'$'
	return ret
end #def
def CodeBase.gitStatus(&process_status)
	return `git status --porcelain`.split("\n").each do |line| 
		status,file=line.split(" ")
		process_status.call(status,file)
	end #each
end #def
# stage target and source files when all tests pass.
# stage model file and .yml files when BOTH unit and controller tests pass
def CodeBase.why_not_stage_helper(file,target,sources,test_type)
	if File.exists?(target) then
		#~ puts "Target #{target}  does exist." 
		if log_passed?(target) then
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

end #def
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
		why_not_stage_helper(file,controller_target(singular_table),controller_sources(singular_table),:controller)  if match_spec[:test_type] != :unit
	end #if
end #def
end #odule CodeBase
