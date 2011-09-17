class TestRun < ActiveRecord::Base
include Generic_Table
has_many :bugs
def initialize(testType=nil, singular_table=nil, plural_table=nil, test=nil)
	if testType.instance_of?(Hash) then
		super(testType) # actually hash of attributes
#		attributes=testType 
	else
		super(nil) #
		if !testType.nil? then
			raise "initialize test run with bad testType=#{testType}" unless [:unit,:controller].include?(testType.to_sym)
			test_type=testType
			table=ENV["TABLE"]
			if singular_table.nil? then
				if plural_table.nil? then
					@singular_table = "code_base"
					@plural_table = "code_bases"
				else
					@singular_table = plural_table.singularize
					@plural_table = plural_table
				end #if
			else
				if plural_table.nil? then
					@singular_table = singular_table
					@plural_table = singular_table.pluralize
				else
					@singular_table = singular_table
					@plural_table = plural_table
				end #if
			end #if
			model = plural_table # canonical form since plurals are more irregular?
			if test.nil? then
				test = ENV["TEST"] 
			end #if
		end #if

	end #if
end #initialize
def run
end #run
def TestRun.ruby_run_and_log(ruby_source,log_file,test=nil)
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
		#c#		puts "local_variables=#{local_variables.inspect}"
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
	puts  '-StandardError Error: ' + exception_raised.inspect 
	puts exception_raised.backtrace.join("\n")

	return true
rescue SyntaxError => exception_raised
	puts  '-SyntaxError Error: ' + exception_raised.inspect 
	return true
end #ruby_run_and_log
def TestRun.file_bug_reports(ruby_source,log_file,test=nil)
	table,test_type=CodeBase.test_type_from_source(ruby_source)
	header,errors,summary=parse_log_file(log_file)
	if summary.nil? then
	else
		tests,assertions,failures,tests_stop_on_error=parse_summary(summary)
		#~ puts "failures+tests_stop_on_error=#{failures+tests_stop_on_error}"
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
	#~ puts "file_bug_reports stop=#{stop}"
	return stop
end #def
def TestRun.summarize
	sh %Q(ls -1 -s log/{unit,functional}|grep " 0 "|cut --delim=' ' -f 3 >log/empty_tests.tmp)	
	sh %Q{grep "[0-9 ,][0-9 ][1-9] error" log/{unit,functional}/* | cut --delim='/' -f 3  >log/error_tests.tmp}
	sh %Q{grep "[0-9 ,][0-9 ][1-9] failures," log/{unit,functional}/* | cut --delim='/' -f 3  >log/failure_tests.tmp}
	sh %Q{cat log/empty_tests.tmp log/error_tests.tmp log/failure_tests.tmp|sort|uniq >log/failed_tests.log}
end #def
end #class
