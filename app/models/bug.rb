require "app/models/generic_table.rb"
class Bug < ActiveRecord::Base
has_many :test_runs
include Generic_Table
def logical_primary_key
	return :url
end #def
def initialize(test_type=nil,table=nil,error=nil)
	return if test_type==nil
	if test_type.instance_of?(Hash) then
		super(test_type) # actually hash of attributes
#		attributes=testType 
	else
		super(nil)
	error.scan(/  ([0-9]+)[)] ([A-Za-z]+):\n(test_[a-z_]*)[(]([a-zA-Z]+)[)]:?\n(.*)$/m) do |number,error_type,test,klass,report|
		#~ puts "number=#{number.inspect}"
		#~ puts "error_type=#{error_type}"
		#~ puts "test=#{test.inspect}"
		#~ puts "klass=#{klass.inspect}"
		#~ puts "report=#{report.inspect}"
		self.url="rake testing:#{test_type}_test TABLE=#{table} TEST=#{test}"
		if error_type=='Error' then
			report.scan(/^([^\n]*)\n(.*)$/m) do |error,trace|
				self[:context]=trace.split("\n")
				puts "error=#{error.inspect}"
				puts "trace=#{trace.inspect}"
				puts "context=#{context.inspect}"
				open('db/bugs.sql',"a" ) {|f| f.write("insert into bugs(url,error,context,created_at,updated_at) values('#{url}','#{error.tr("'",'`')}','#{context}','#{Time.now.rfc2822}','#{Time.now.rfc2822}');\n") }						
			end #scan
		elsif error_type=='Failure' then
			report.scan(/^\s*[\[]([^\]]+)[\]]:\n(.*)$/m) do |trace,error|
				self[:context]=trace.split("\n")
				self[:error]=error.slice(0,50)
				puts "error=#{error.inspect}"
				puts "trace=#{trace.inspect}"
				puts "context=#{context.inspect}"
				open('db/bugs.sql',"a" ) {|f| f.write("insert into bugs(url,error,context,created_at,updated_at) values('#{url}','#{error.tr("'",'`')}','#{context}','#{Time.now.rfc2822}','#{Time.now.rfc2822}');\n") }						
			end #scan
		else
			puts "pre_match=#{s.pre_match}"
			puts "post_match=#{s.post_match}"
			puts "before #{s.rest}"
		end #if
	end #scan
	end #if
end #parse_bug
def short_context
	return self.context.reverse[1..-1].collect{|t| t.slice(/`([a-zA-Z_]+)'/,1)}.join(', ')
end #def
end # class
