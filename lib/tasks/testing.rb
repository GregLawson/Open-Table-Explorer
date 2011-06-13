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
FILE_MOD_TIMES=ALL_MODEL_FILES.map { |model_file| [model_file,File.mtime(model_file)]}.sort! {|x,y| y[1] <=> x[1] } # sort on file mod times

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
	
#	puts "FILE_MOD_TIMES=#{FILE_MOD_TIMES.inspect}"
	FILE_MOD_TIMES .each do |file_mod_time|
		model_file=file_mod_time[0]
		 singular_table=model_file.sub(/^app\/models\//,'').sub(/[.]rb$/,'')
		stop=conditional_build(unit_target(singular_table), unit_sources(singular_table))
		return stop if stop

		stop=conditional_build(controller_target(singular_table), controller_sources(singular_table))
		return stop if stop
	end #each

end #def

def short_context(trace)
	return trace.reverse[1..-1].collect{|t| t.slice(/`([a-zA-Z_]+)'/,1)}.join(', ')
end #def
def after(s,before,pattern)
	if s.scan_until(before).nil? then
		puts "before #{s.rest[0..50]}, #{pattern.to_s} not matched."
	else
		puts "matched at #{s.matched} after #{before}"
		ret=s.scan(pattern)
		if ret.nil? then
			puts "before #{s.rest[0..50]}, #{pattern.to_s} not matched."
			return nil
		else
			return ret
		end
	end
end #def
def stage
		gitStatus=`git status --porcelain`.split("\n").each do |s|
		status,file=s.split(" ")
		pp "status",status
		pp "file",file
		why_not_stage(file,"acquisition_stream_spec")
	end #map
end #def
def table_type_from_source(ruby_source)
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
end #def
def parse_summary(summary)
	summary=summary.split(' ')
	tests=summary[0]
	assertions=summary[2]
	failures=summary[4]
	tests_stop_on_error=summary[6]
	return [tests,assertions,failures,tests_stop_on_error]
end #def
def parse_bug(test_type,table,error)
	error.scan(/  ([0-9]+)[)] ([A-Za-z]+):\n(test_[a-z_]*)[(]([a-zA-Z]+)[)]:?\n(.*)$/m) do |number,error_type,test,klass,report|
		#~ puts "number=#{number.inspect}"
		#~ puts "error_type=#{error_type}"
		#~ puts "test=#{test.inspect}"
		#~ puts "klass=#{klass.inspect}"
		#~ puts "report=#{report.inspect}"
		url="rake testing:#{test_type}_test TABLE=#{table} TEST=#{test}"
		if error_type=='Error' then
			report.scan(/^([^\n]*)\n(.*)$/m) do |error,trace|
				context=short_context(trace.split("\n"))
				#~ puts "error=#{error.inspect}"
				#~ puts "trace=#{trace.inspect}"
				#~ puts "context=#{context.inspect}"
				open('db/bugs.sql',"a" ) {|f| f.write("insert into bugs(url,error,context,created_at,updated_at) values('#{url}','#{error.tr("'",'`')}','#{context}','#{Time.now.rfc2822}','#{Time.now.rfc2822}');\n") }						
			end #scan
		elsif error_type=='Failure' then
			report.scan(/^\s*[\[]([^\]]+)[\]]:\n(.*)$/m) do |trace,error|
				context=short_context(trace.split("\n"))
				error=error.slice(0,50)
				#~ puts "error=#{error.inspect}"
				#~ puts "trace=#{trace.inspect}"
				#~ puts "context=#{context.inspect}"
				open('db/bugs.sql',"a" ) {|f| f.write("insert into bugs(url,error,context,created_at,updated_at) values('#{url}','#{error.tr("'",'`')}','#{context}','#{Time.now.rfc2822}','#{Time.now.rfc2822}');\n") }						
			end #scan
		else
			puts "pre_match=#{s.pre_match}"
			puts "post_match=#{s.post_match}"
			puts "before #{s.rest}"
		end #if
	end #scan
end #def
def parse_log_file(log_file)
	blocks=IO.read(log_file).split("\n\n")# delimited by multiple successive newlines
#	puts "blocks=#{blocks.inspect}"
	header= blocks[0]
	errors=blocks[1..-2]
	summary=blocks[-1]
	return [header,errors,summary]
end #def
def log_passed?(log_file)
	if !File.size?(log_file) then
		return false # no file or empty file, no evidence of passing
	end #if
	header,errors,summary=parse_log_file(log_file)
	if summary.nil? then
	else
		tests,assertions,failures,tests_stop_on_error=parse_summary(summary)
		if    (failures+tests_stop_on_error)==0 then
			return true
		else
			return false
		end #if
	end #if
end #def
def file_bug_reports(ruby_source,log_file,test=nil)
	table,test_type=table_type_from_source(ruby_source)
	header,errors,summary=parse_log_file(log_file)
	if summary.nil? then
	else
		tests,assertions,failures,tests_stop_on_error=parse_summary(summary)
		if    (failures+tests_stop_on_error)==0 then
			stop=false
		else
			stop=true
		end #if
		open('db/tests.sql',"a" ) {|f| f.write("insert into test_runs(model,test,test_type,environment,tests,assertions,failures,tests_stop_on_error,created_at,updated_at) values('#{table}','#{ENV["TEST"]}','#{test_type}','#{ENV["RAILS_ENV"]}',#{tests},#{assertions},#{failures},#{tests_stop_on_error},'#{Time.now.rfc2822}','#{Time.now.rfc2822}');\n") }
	end #if
	if !errors.nil? then
		errors.each do |error|
			parse_bug(test_type,table,error)
		end #each
	end #if 
#	puts "ARGF.argv.inspect=#{ARGF.argv.inspect}"
#	puts "file_bug_reports stop=#{stop}"
	return stop
end #def
def summarize
	sh %Q(ls -1 -s log/{unit,functional}|grep " 0 "|cut --delim=' ' -f 3 >log/empty_tests.tmp)	
	sh %Q{grep "[0-9 ,][0-9 ][1-9] error" log/{unit,functional}/* | cut --delim='/' -f 3  >log/error_tests.tmp}
	sh %Q{grep "[0-9 ,][0-9 ][1-9] failures," log/{unit,functional}/* | cut --delim='/' -f 3  >log/failure_tests.tmp}
	sh %Q{cat log/empty_tests.tmp log/error_tests.tmp log/failure_tests.tmp|sort|uniq >log/failed_tests.log}
end #def
def view(url)
	uri=URI(url)
	output_file='log/view/test.html'
	old=IO.read('log/production.log')
	sh "curl #{url} -o #{output_file}"
	new=IO.read('log/production.log')
	changes=new[old.size..-1]
	puts "changes=#{changes}"
end #def
