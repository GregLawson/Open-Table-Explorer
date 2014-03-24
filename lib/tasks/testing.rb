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

end #work_flow

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
def view(url)
	uri=URI(url)
	output_file='log/view/test.html'
	old=IO.read('log/production.log')
	sh "curl #{url} -o #{output_file}"
	new=IO.read('log/production.log')
	changes=new[old.size..-1]
	puts "changes=#{changes}"
end #def
