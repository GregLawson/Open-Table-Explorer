def ruby_run_and_log(ruby_source,log_file,test=nil)
	if test.nil? then
		ruby_test=ruby_source
	else
		ruby_test="#{ruby_source} -n #{test}"
	end #if
	stop=ruby %Q{-I test #{ruby_test} | tee #{log_file}}  do |ok, res|
		if  ok
#always happens			puts "ruby ok(status = #{res.inspect})"
			#~ sh "git add #{ruby_source}"
			#~ puts IO.read(log_file)
		else
			puts "ruby failed(status = #{res.exitstatus})!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
			#~ sh "tail --lines=2 #{log_file}"
		end
#		puts "calling file_bug_reports"
		stop=file_bug_reports(ruby_source,log_file,test)
#		puts "return from file_bug_reports. stop=#{stop}"
#		puts "local_variables=#{local_variables.inspect}"
		return stop
	end # ruby
	if local_variables.include?('stop') then
		puts "stop is defined here."
		return stop
	else
		puts "stop is nil or undefined? local_variables=#{local_variables.inspect}"
		puts "Did ruby block not execute?"
		return true
	end
rescue StandardError => exception_raised
	puts  'StandardError Error: ' + exception_raised.inspect 
	puts exception_raised.backtrace.join("\n")

	return true
rescue SyntaxError => exception_raised
	puts  'SyntaxError Error: ' + exception_raised.inspect 
	return true
end #def
def full_unit_test(plural_table,test)
	singular_table=plural_table.singularize
	stop=ruby_run_and_log("test/unit/#{singular_table}_test.rb", "log/unit/#{singular_table}_test.log")
	return stop if stop
	stop=ruby_run_and_log("test/functional/#{plural_table}_controller_test.rb", "log/functional/#{plural_table}_controller_test.log",test) # only?
	return stop
end #def
def unit_test(plural_table,test=nil)
	singular_table=plural_table.singularize
	stop=ruby_run_and_log("test/unit/#{singular_table}_test.rb", "log/unit/#{singular_table}_test.log",test)
	return stop
end #def
def controller_test(plural_table,test=nil)
	singular_table=plural_table.singularize
	stop=ruby_run_and_log("test/functional/#{plural_table}_controller_test.rb", "log/functional/#{plural_table}_controller_test.log",test) #
	return stop
end #def
def conditional_build(target, sources)
	sources.each do |s|
		if !uptodate?(target, s)  then
#			puts "not up to date."
#			sh ("ls -l #{target}") {|ok, res| } # discard result if file doesn't exist
#			sh "ls -l #{s}"
		end
	end #each
	not_uptodate_sources=sources.select {|s|  !uptodate?(target, s) && 	File.exist?(s) }
	if uptodate?(target, sources) then
		stop=false
	else
		if !File.exist?(target) then
			return false
		end #if
		stop=ruby_run_and_log(sources[0], target)
		if !stop then
			not_uptodate_sources.each do |s|
				sh "git add #{s}"
			end #each
		end #if
	end #file
	return stop
end #def
ALL_MODEL_FILES=Dir['app/models/*.rb']
#	puts "ALL_MODEL_FILES=#{ALL_MODEL_FILES.inspect}"
AFFECTS_EVERYTHING=["db/schema.rb","test/test_helper.rb",'app/models/global.rb','app/models/generic_table.rb']
AFFECTS_CONTROLLERS=Dir['app/views/shared/*']
def unit_sources(singular_table)
	plural_table=singular_table.pluralize
	# commn_sources apply to both unit and functional tests.
	model_file="app/models/#{singular_table}.rb"
	common_sources=AFFECTS_EVERYTHING+[model_file,"test/fixtures/#{plural_table}.yml"]
	return ["test/unit/#{singular_table}_test.rb"]+common_sources
end #def
def controller_sources(singular_table)
	plural_table=singular_table.pluralize
	# commn_sources apply to both unit and functional tests.
	model_file="app/models/#{singular_table}.rb"
	common_sources=AFFECTS_EVERYTHING+[model_file,"test/fixtures/#{plural_table}.yml"]
	sources=common_sources+Dir["app/views/#{plural_table}/*.html.erb "]+AFFECTS_CONTROLLERS
	return ["test/functional/#{plural_table}_controller_test.rb"] +sources+["app/controllers/#{plural_table}_controller.rb","app/helpers/#{plural_table}_helper.rb"]
end #def
def unit_target(singular_table)
	return "log/unit/#{singular_table}_test.log"
end #def
def controller_target(singular_table)
	plural_table=singular_table.pluralize
	return "log/functional/#{plural_table}_controller_test.log"
end #def

def workFlow(test=nil) 
	Dir['log/unit/*.log'].select {|f| !File.size?(f) }.each do |f|
		sh %Q(ls -1 -s #{f})	
		rm f
	end #each
	Dir['log/functional/*.log'].select {|f| !File.size?(f) }.each do |f|
		sh %Q(ls -1 -s #{f})	
		rm f
	end #each
	
	file_mod_times=ALL_MODEL_FILES.map do |model_file|
		[model_file,File.mtime(model_file)]
	end #map
	file_mod_times.sort! {|x,y| y[1] <=> x[1] } # sort on file mod times
#	puts "file_mod_times=#{file_mod_times.inspect}"
	file_mod_times .each do |file_mod_time|
		model_file=file_mod_time[0]
		 singular_table=model_file.sub(/^app\/models\//,'').sub(/[.]rb$/,'')
		stop=conditional_build(unit_target(singular_table), unit_sources(singular_table))
		return stop if stop

		stop=conditional_build(controlller_target(singular_table), controller_sources(singular_table))
		return stop if stop
	end #each

end #def
def why_not_stage(file,singular_table)
	puts "#{file} not a unit source."unless unit_sources(singular_table).include?(file)
	puts "#{file} not a controller source."unless controller_sources(singular_table).include?(file)
	target=target
	puts "#{file} not up to date."unless  uptodate?(target,[file]) 
	puts "Target #{target}  does not exist."unless  File.exist?(target) 
end #def
def stage
		gitStatus=`git status --porcelain`.split("\n").each do |s|
		status,file=s.split(" ")
		pp "status",status
		pp "file",file
		why_not_stage(file,"acquisition_stream_spec")
	end #map
end #def