require "app/models/generic_table.rb"
class Bug < ActiveRecord::Base
has_many :test_runs
belongs_to :error_type

include Generic_Table
def self.logical_primary_key
	return [:created_at]
end #def
def initialize(test_type=nil,table=nil,error=nil)
	if test_type==nil then
		super(nil)
		return
	elsif test_type.instance_of?(Hash) || test_type.instance_of?(ActiveSupport::HashWithIndifferentAccess) then
		puts "hash parameter=#{test_type}"
		super(test_type) # actually hash of attributes
#		attributes=testType 
	else
		puts "not hash, not empty: test_type.class=#{test_type.class}, test_type=#{test_type.inspect}, table=#{table}, error='#{error}'"
		super(nil)
		raise "not hash, not empty:  test_type.class=#{test_type.class}, test_type=#{test_type.inspect}, table=#{table}, error=#{error}" if error.nil?
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
				puts "error='#{error.inspect}'"
				puts "trace='#{trace.inspect}'"
				puts "context=#{context.inspect}"
				open('db/bugs.sql',"a" ) {|f| f.write("insert into bugs(url,error,context,created_at,updated_at) values('#{url}','#{error.tr("'",'`')}','#{context}','#{Time.now.rfc2822}','#{Time.now.rfc2822}');\n") }						
			end #scan
		elsif error_type=='Failure' then
			report.scan(/^\s*[\[]([^\]]+)[\]]:\n(.*)$/m) do |trace,error|
				self[:context]=trace.split("\n")
				self[:error]=error.slice(0,50)
				puts "error='#{error.inspect}'"
				puts "trace='#{trace.inspect}'"
				puts "context='#{context.inspect}'"
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
