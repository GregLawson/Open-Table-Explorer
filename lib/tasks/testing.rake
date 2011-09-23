 Rake::RDocTask.new do |rd|
    rd.main = "allservers.sh "
    rd.rdoc_files.include("app/**/*.rb")
  end
require 'active_support' # for singularize and pluralize
# syntax http://rake.rubyforge.org/
require 'lib/tasks/testing.rb'
require 'app/models/global.rb'
require 'app/models/generic_table.rb'
require 'app/models/code_base.rb'
require 'app/models/test_run.rb'
ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database => "db/production.sqlite3",
  :pool => 5,
  :timeout => 5000)
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
	work_flow(test) if !stop
#	summarize
	stage
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
	stage
end #task
task :summarize do
	summarize
end #task
task :unit_test do
TestRun.new(:unit, ENV["TABLE"], ENV["TABLE"], ENV["TEST"]).run

exit
	plural_table = ENV["TABLE"].pluralize  || "code_bases"
	test = ENV["TEST"] 
	unit_test(plural_table,test)
#	summarize
end #task
task :controller_test do
	plural_table = ENV["TABLE"].pluralize || "code_bases"
	test = ENV["TEST"]
	controller_test(plural_table,test)
#	summarize
end #task
task :full_unit_test do
	plural_table = ENV["TABLE"].pluralize  || "accounts"
	test = ENV["TEST"]
	full_unit_test(plural_table,test)
#	summarize
	stage
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
task :view do
	url = ENV["URL"]
	view(url)
end #test
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