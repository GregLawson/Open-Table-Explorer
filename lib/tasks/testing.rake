 Rake::RDocTask.new do |rd|
    rd.main = "allservers.sh "
    rd.rdoc_files.include("app/**/*.rb")
  end
require 'active_support' # for singularize and pluralize
# syntax http://rake.rubyforge.org/
require 'lib/tasks/testing.rb'
namespace :testing do

desc "Run tests testing:incremental, testing:full, testing:summarize, or testing:unit_test TABLE=plural_table TEST=. Output in log/{unit,functional}/"
directory "log/full"
task :stage do
	stage
	sh "git-cola"
end #def
task :update_master do
	 sh %{git checkout master} do |ok, res|
		if ok
			 sh %{git merge development} do |ok, res|
				if ok
					puts "git merge development ok (status = #{res.exitstatus})"					
					 sh %{git checkout development} do |ok, res|
						if ok
							puts "git checkout development ok (status = #{res.exitstatus})"					
						else
							puts "git checkout development failed (status = #{res.exitstatus})"
						end #if
					end #sh			
				else
					puts "git merge development failed (status = #{res.exitstatus})"
				end #if
			end #sh			
		else
			puts "git checkout failed (status = #{res.exitstatus})"
			 sh %{git-cola} do |ok, res|
				if ok
					puts "git cola ok (status = #{res.exitstatus})"					
				else
					puts "git cola failed (status = #{res.exitstatus})"
				end #if
			end #sh
		end #if
	  end #sh

end #task	
task :push do
	 sh %{git checkout master} do |ok, res|
		if ok
			 sh %{git merge development} do |ok, res|
				if ok
					puts "git merge development ok (status = #{res.exitstatus})"					
					 sh %{git push} do |ok, res|
						if ok
							puts "git push ok (status = #{res.exitstatus})"					
							 sh %{git checkout development} do |ok, res|
								if ok
									puts "git checkout development ok (status = #{res.exitstatus})"					
								else
									puts "git checkout development failed (status = #{res.exitstatus})"
								end #if
							end #sh			
						else
							puts "git push failed (status = #{res.exitstatus})"
						end #if
					end #sh			
				else
					puts "git merge development failed (status = #{res.exitstatus})"
				end #if
			end #sh			
		else
			puts "git checkout failed (status = #{res.exitstatus})"
			 sh %{git-cola} do |ok, res|
				if ok
					puts "git cola ok (status = #{res.exitstatus})"					
				else
					puts "git cola failed (status = #{res.exitstatus})"
				end #if
			end #sh
		end #if
	  end #sh


end #task
task :work_flow do
	puts "starting work_flow"
	if ENV["TABLE"] then
		plural_table = ENV["TABLE"].pluralize 
		stop=full_unit_test(plural_table,test)
	else
		stop=false # want to do something
	end #if
	test = ENV["TEST"]
	workFlow(test) if !stop
#	summarize
end #task
task :incremental do
	ALL_MODEL_FILES .each do |model_file|
		 singular_table=model_file[11..-4]
		 plural_table=singular_table.pluralize
		 model_file="app/models/#{singular_table}.rb"
		target = "log/unit/#{singular_table}_test.log"
		conditional_build(target, unit_sources(singular_table))
		
		target = "log/functional/#{plural_table}_controller_test.log"
		conditional_build(target, controller_sources(singular_table))
	end #each
	summarize
end #task
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
def file_bug_reports(ruby_source,log_file,test=nil)
	path=Pathname.new(ruby_source)
	#~ puts "path=#{path.inspect}"
	words=path.basename.to_s.split('_')
#	puts "words=#{words.inspect}"
	raise "not a test pathname =#{path.inspect}" if words[-1]!='test.rb'
	if words[-2]=='controller' then
		test_type='functional'
		table=words[0..-3].join('_')
	else
		test_type='unit'
		table=words[0..-2].join('_')
	end #if
	#~ puts "test_type='#{test_type}'"
	blocks=IO.read(log_file).split("\n\n")# delimited by multiple successive newlines
#	puts "blocks=#{blocks.inspect}"
	header= blocks[0]
	errors=blocks[1..-2]
	summary=blocks[-1]
	if summary.nil? then
	else
		#~ puts "summary=#{summary.split(' ').inspect}"
		summary=summary.split(' ')
		tests=summary[0]
		assertions=summary[2]
		failures=summary[4]
		tests_stop_on_error=summary[6]
		if    (failures+tests_stop_on_error)==0 then
			stop=false
		else
			stop=true
		end #if
		open('db/tests.sql',"a" ) {|f| f.write("insert into test_runs(model,test,test_type,environment,tests,assertions,failures,tests_stop_on_error,created_at,updated_at) values('#{table}','#{ENV["TEST"]}','#{test_type}','#{ENV["RAILS_ENV"]}',#{tests},#{assertions},#{failures},#{tests_stop_on_error},'#{Time.now.rfc2822}','#{Time.now.rfc2822}');\n") }
	end #if
	if !errors.nil? then
		errors.each do |error|
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
task :summarize do
	summarize
end #task
task :unit_test do
	plural_table = ENV["TABLE"].pluralize  || "accounts"
	test = ENV["TEST"] 
	unit_test(plural_table,test)
#	summarize
end #task
task :controller_test do
	plural_table = ENV["TABLE"].pluralize || "accounts"
	test = ENV["TEST"]
	controller_test(plural_table,test)
#	summarize
end #task
task :full_unit_test do
	plural_table = ENV["TABLE"].pluralize  || "accounts"
	test = ENV["TEST"]
	full_unit_test(plural_table,test)
#	summarize
end #task
task :full do	
	sh "rake test:units >log/full/rake_test.log"
	sh "rake test:functionals >log/full/rake_controller_test.log"
	FileList['app/models/*.rb'].each do |model_file|
		 singular_table=model_file[11..-4]
		  full_unit_test(singular_table.pluralize)
	  end #each
	  sh 'rdoc'
	summarize
end #task
def view(url)
	uri=URI(url)
	output_file='log/view/test.html'
	old=IO.read('log/production.log')
	sh "curl #{url} -o #{output_file}"
	new=IO.read('log/production.log')
	changes=new[old.size..-1]
	puts "changes=#{changes}"
end #def
task :view do
	url = ENV["URL"]
	view(url)
end #test
task :change_test do
	sh "ruby unit/account_test.rb >log/unit/account_test.lis"
	sh "ruby unit/transfer_test.rb "
	sh "ruby unit/table_spec_test.rb "
	sh "ruby unit/acquisition_interface_test.rb "
	sh "ruby unit/acquisition_stream_spec_test.rb "
	sh "ruby unit/acquisition_test.rb "
	sh "#ruby functional/acquisition_controller_test.rb "
	sh "ruby functional/accounts_controller_test.rb "
	sh "ruby functional/transfers_controller_test.rb "
	sh "ruby functional/table_specs_controller_test.rb "
	sh "ruby functional/acquisitions_controller_test.rb "
	sh "ruby functional/acquisition_stream_specs_controller_test.rb "
	sh "ruby functional/acquisition_interfaces_controller_test.rb "
end
wiki_directory='../Open-Table-Explorer.wiki'
directory wiki_directory

task :wiki_toc do
	wiki_files=FileList["#{wiki_directory}/*"]
	delete_regexp=%r{^../[a-zA-Z0-9-.]+/}
	parse_reference_regexp=%r{\[\[([0-9\/.]*)?-?\s?([a-z-A-Z0-9? '-]+)\]\]|\[https://github.com/GregLawson/Open-Table-Explorer/wiki/([0-9\/.]*)?-?([a-z-A-Z0-9%?'-]+) [a-zA-Z0-9 ]+\]}
	parse_filename_regexp=%r{([0-9\/.]*)-?([a-z-A-Z0-9-?']+)[.]([a-z]+)}
	sections={}
	wiki_files.map do |f|
		hash={}
		f.sub!(delete_regexp,'')
		parse=parse_filename_regexp.match(f)
		if parse.nil? then
			puts "filename not parsed: #{f}"
		else
			hash[:section_number]=parse[1]
			hash[:filename]=parse[2]
			hash[:extension]=parse[3]
			sections[parse[2].downcase.strip]=hash
		end #if
	end #mapo
	#~ puts "sections=#{sections.inspect}"
	sections.each do |fileKey,hash|
		#~ puts "fileKey=#{fileKey}"
		#~ puts "hash=#{hash.inspect}"
		if ['md','mediawiki','creole'].include?(hash[:extension]) then
			path=wiki_directory+'/'+hash[:section_number]+"-"+hash[:filename]+'.'+hash[:extension]
			if !File.exist?(path) then
				puts "Path #{path} is not in standard form. Check for section number and dash between section number and name."
			else
				write_path=wiki_directory+'/updated/'+hash[:section_number]+"-"+hash[:filename]+'.'+hash[:extension]			
				open(write_path,'w') do |write_file|
					searchText=IO.read(path)
					begin
						#~ puts "readline: #{line}"
						matchData=parse_reference_regexp.match(searchText) 
						if matchData then					
							write_file.print matchData.pre_match # pass through unchanged text
							#~ puts "found: matchData=#{matchData.inspect}"
							if matchData[4].nil? then
								referenced_section_name=matchData[2] # section number is updated if it exists
							else
								referenced_section_name=matchData[4] # section number is updated if it exists
							end
							key=referenced_section_name.strip.gsub(' ','-').downcase # canonical name, see above
							#~ puts "key=#{key}"
							newHash=sections[key]
							#~ puts "newHash=#{newHash.inspect}"
							if newHash.nil? then
								puts "Reference to nonexistant section named '#{key}' in file #{path}. "
								write_file.print matchData[0] # leave it unchanged for manual editting
							else
								newRef='&sect;[['+newHash[:section_number]+'-'+referenced_section_name+']]'
								if matchData[1] != newHash[:section_number] then
									puts "#{matchData[0]} becomes #{newRef}" # changed section number
								else
									if newRef==matchData[0]  then
										#~ puts "#{matchData[0]} stays #{'[['+newRef+']]'}" # unchangedchanged section number
									else
										puts "#{matchData[0]} reformatted to #{newRef}" # unchangedchanged section number
									end
								end
								write_file.print newRef # update reference, format even if section number doesn't change
							end #if
							searchText=matchData.post_match
						else
							write_file.print searchText # pass through text after all matches
						end #if
					end while matchData #begin
				end #open
			end #if
		end #if
	end #each
end #task
end # namespace testing