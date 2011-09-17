def full_unit_test(plural_table,test)
	singular_table=plural_table.singularize
	stop=TestRun.ruby_run_and_log("test/unit/#{singular_table}_test.rb", "log/unit/#{singular_table}_test.log")
	return stop if stop
	stop=TestRun.ruby_run_and_log("test/functional/#{plural_table}_controller_test.rb", "log/functional/#{plural_table}_controller_test.log",test) # only?
	return stop
end #def
def unit_test(plural_table,test=nil)
	singular_table=plural_table.singularize
	target="log/unit/#{singular_table}_test.log"
	sources=CodeBase.unit_sources(singular_table)
	not_uptodate_sources=sources.select {|s| !File.exist?(target) ||  File.exist?(s) && !uptodate?(target, s)}
	stop=TestRun.ruby_run_and_log("test/unit/#{singular_table}_test.rb", target,test)
	if !stop then
		CodeBase.git_add_successful(not_uptodate_sources)
	end #if
	return stop
end #def
def controller_test(plural_table,test=nil)
	singular_table=plural_table.singularize
	stop=TestRun.ruby_run_and_log("test/functional/#{plural_table}_controller_test.rb", "log/functional/#{plural_table}_controller_test.log",test) #
	return stop
end #def
def conditional_build(target, sources)
	sources.each do |s|
		if !File.exist?(s) then
			puts "#{s} does not exist."
		elsif !uptodate?(target, s)  then
			puts "not up to date."
			sh ("ls -l #{target}") {|ok, res| } # discard result if file doesn't exist
			sh "ls -l #{s}"
		end
	end #each
	if uptodate?(target, sources) then
		stop=false
	else
#		if !File.exist?(target) then
#			return false
#		end #if
		not_uptodate_sources=sources.select {|s| !File.exist?(target) ||  File.exist?(s) && !uptodate?(target, s)}
		stop=TestRun.ruby_run_and_log(sources[0], target)
		if !stop then
			CodeBase.git_add_successful(not_uptodate_sources)
		end #if
	end #file
	return stop
end #def

def work_flow(test=nil) 
	Dir['log/unit/*.log'].select {|f| !File.size?(f) }.each do |f|
		sh %Q(ls -1 -s #{f})	
		rm f
	end #each
	Dir['log/functional/*.log'].select {|f| !File.size?(f) }.each do |f|
		sh %Q(ls -1 -s #{f})	
		rm f
	end #each
	
#	puts "CodeBase::FILE_MOD_TIMES=#{CodeBase::FILE_MOD_TIMES.inspect}"
	CodeBase.not_uptodate_order do |target_file, sources|
	ruby_source=CodeBase.test_program_from_file(target_file)
		stop=TestRun.ruby_run_and_log(ruby_source,target_file)
		return stop
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
	CodeBase.gitStatus do|status,file| 
		if status != 'D' then
			CodeBase.why_not_stage(file,CodeBase.singular_table_from_file(file))
		end #if
	end #gitStatus
end #def
def parse_summary(summary)
	summary=summary.split(' ')
	tests=summary[0].to_i
	assertions=summary[2].to_i
	failures=summary[4].to_i
	tests_stop_on_error=summary[6].to_i
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
def view(url)
	uri=URI(url)
	output_file='log/view/test.html'
	old=IO.read('log/production.log')
	sh "curl #{url} -o #{output_file}"
	new=IO.read('log/production.log')
	changes=new[old.size..-1]
	puts "changes=#{changes}"
end #def
