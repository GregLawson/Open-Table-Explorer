<<<<<<< HEAD
 Rake::RDocTask.new do |rd|
    rd.main = "allservers.sh "
    rd.rdoc_files.include("app/**/*.rb")
  end
require 'active_support' # for singularize and pluralize
# syntax http://rake.rubyforge.org/
namespace :testing do

desc "Run tests testing:incremental, testing:full, testing:summarize, or testing:unit_test TABLE=plural_table . Output in log/{unit,functional}/"
directory "log/full"
=======
require 'active_support'
# syntax http://rake.rubyforge.org/
namespace :testing do

desc "Run tests testing:incremental, testing:full, or testing:unit_test TABLE=plural_table . Output in log/{unit,functional}/"
directory "log/unit"
>>>>>>> 6edf09d775fff29132398b48342e8e030993c902
def build_table(singular_table)
	 plural_table=singular_table.pluralize
	 model_file="app/models/#{singular_table}.rb"
	 # commn_sources apply to both unit and functional tests.
	 common_sources=[model_file,"db/schema.rb","test/test_helper.rb","test/fixtres/#{plural_table}.yml"]
	target = "log/unit/#{singular_table}_test.log"
	sources=["test/unit/#{singular_table}_test.rb"]+common_sources
<<<<<<< HEAD
	sources.each do |s|
		if !uptodate?(target, s)  then
			puts "not uptodate."
			sh "ls -l #{target}"
			sh "ls -l #{s}"
		end
	end #def
=======
	#~ puts "target=#{target.inspect}"
	#~ puts "sources=#{sources.inspect}"
	#~ puts "uptodate?(target, sources)=#{uptodate?(target, sources) }"
>>>>>>> 6edf09d775fff29132398b48342e8e030993c902
	unless uptodate?(target, sources) 
		ruby_run_and_log(sources[0], target)
	end #file
	target = "log/functional/#{plural_table}_controller_test.log"
	sources=common_sources+FileList["app/views/#{plural_table}/*.html.erb "]
	sources=["test/functional/#{plural_table}_controller_test.rb"] +sources+["app/controller/#{plural_table}_controller.rb","app/helpers/#{plural_table}"]
	unless uptodate?(target, sources) 
		ruby_run_and_log(sources[0], target)
	end #file
end #def
def ruby_run_and_log(ruby_source,log_file)
	ruby %Q{-I test #{ruby_source} >#{log_file}}  do |ok, res|
		if ! ok
			# puts "ruby failed(status = #{res.exitstatus})"
			puts IO.read(log_file)
		else
			sh "tail --lines=2 #{log_file}"
		end
	end # ruby
end #def
def full_unit_test(plural_table)
	singular_table=plural_table.singularize
	ruby_run_and_log("test/unit/#{singular_table}_test.rb", "log/unit/#{singular_table}_test.log")
	ruby_run_and_log("test/functional/#{plural_table}_controller_test.rb", "log/functional/#{plural_table}_controller_test.log")
end #def
def summarize
<<<<<<< HEAD
	sh %Q(ls -1 -s log/{unit,functional}|grep " 0 "|cut --delim=' ' -f 3 >log/failed_tests.tmp)	
	sh %Q{grep "[0-9 ,][0-9 ][1-9] error" log/{unit,functional}/* | cut --delim='/' -f 3  >>log/failed_tests.tmp}
	sh %Q{grep "[0-9 ,][0-9 ][1-9] failures," log/{unit,functional}/* | cut --delim='/' -f 3  >>log/failed_tests.tmp}
	sh %Q{sort log/failed_tests.tmp|uniq >log/failed_tests.log}
	rm "log/failed_tests.tmp"
	(IO.readlines("log/failed_tests.log")- IO.readlines("log/arrested_development.log")).each do |f|
		puts f
	end #each
end #def
task :summarize do
	summarize
end #task
=======
	sh %Q(ls -1 -s log/{unit,functional}|grep " 0 "|cut --delim=' ' -f 3 >log/failed_tests.log)	
end #def
>>>>>>> 6edf09d775fff29132398b48342e8e030993c902
task :unit_test do
	plural_table = ENV["TABLE"] || "accounts"
	full_unit_test(plural_table)
	summarize
end #task
task :incremental do
 FileList['app/models/*.rb'].each do |model_file|
	 singular_table=model_file[11..-4]
	 build_table(singular_table)
 end #each
 summarize
end #task
task :full do	
<<<<<<< HEAD
	sh "rake test:units >log/full/rake_test.log"
	sh "rake test:functionals >log/full/rake_controller_test.log"
	FileList['app/models/*.rb'].each do |model_file|
		 singular_table=model_file[11..-4]
		  full_unit_test(singular_table.pluralize)
	 end #each
=======
	sh "rake test:units >log/unit/rake_test.log"
	sh "rake test:functionals >log/functional/rake_test.log"
>>>>>>> 6edf09d775fff29132398b48342e8e030993c902
	summarize
end #task
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
end # namespace testing