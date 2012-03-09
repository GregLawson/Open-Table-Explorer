 Rake::RDocTask.new do |rd|
    rd.main = "allservers.sh "
    rd.rdoc_files.include("app/**/*.rb")
  end
require 'active_support' # for singularize and pluralize
# syntax http://rake.rubyforge.org/
require 'lib/tasks/testing.rb'
require 'app/models/global.rb'
require 'app/models/regexp_parser.rb'
require 'app/models/generic_table_html.rb'
require 'app/models/generic_table_association.rb'
require 'app/models/generic_grep.rb'
require 'app/models/column_group.rb'
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
end #work_flow
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

end #unit_test
task :controller_test do
	TestRun.new(:controller, ENV["TABLE"], ENV["TABLE"], ENV["TEST"]).run
	exit
end #controller_test
task :full_unit_test do
	plural_table = ENV["TABLE"].pluralize  || "accounts"
	TestRun.new(:unit, ENV["TABLE"].singularize, ENV["TABLE"], ENV["TEST"]).run
	TestRun.new(:controller, ENV["TABLE"], ENV["TABLE"].pluralize, ENV["TEST"]).run
	stage
end #task
task :full do	
	sh "rake test:units >log/full/rake_test.log"
	sh "rake test:functionals >log/full/rake_controller_test.log"
	FileList['app/models/*.rb'].each do |model_file|
		 singular_table=model_file[11..-4]
		  full_unit_test(singular_table.pluralize)
	  end #each
	  sh ' rdoc --op ../Open-Table-Explorer-github-pages/doc/ app test lib'
	summarize
end #task
task :rdoc do
	  sh 'bundle exec rdoc --op ../Open-Table-Explorer-github-pages/doc/ app test lib'
end #rdoc
task :view do
	url = ENV["URL"]
	view(url)
end #test
end # namespace testing