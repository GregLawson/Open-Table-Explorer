require "rubygems"
require 'rsruby'
module R_Interface
@r=RSRuby.instance
def self.eval_R(rCommand)
	# Warning: performance is slow for big arrays returned.
	# Try assign big arrays in R
	# return only statistics
	puts "rCommand=#{rCommand}" if $VERBOSE
	sysout= @r.eval_R(rCommand)
	puts "sysout=#{sysout}"
	return sysout
end
def self.psqlExport(tableName)
	#sql="COPY #{tableName} TO '#{tableName}.csv' WITH CSV HEADER "
	sql="COPY #{tableName} TO STDOUT WITH CSV HEADER "
	puts "sql=#{sql}"	
	psql="psql --no-align --tuples-only --host localhost --dbname energy_development --command \"#{sql}\" >/tmp/#{tableName}.csv"
	puts "psql=#{psql}"	
	sysout=`#{psql}`
end
def self.importRelation(tableName)
# 	pv<-read.csv('/home/greg/energy/rails/energy/production.csv')
	eval_R_shell("#{tableName}<-read.csv(\"/tmp/#{tableName}.csv\")")
#	@r.assign("foo",@r.read_csv("/tmp/#{tableName}.csv"))
#	puts @r.foo.size
#	puts @r.read_csv("/tmp/#{tableName}.csv")
end
def self.eval_R_shell(rCommand)
	shellCmd="R --save --quiet -e \'#{rCommand}\'"
	puts "shellCmd=#{shellCmd}" if $VERBOSE
	sysout=`#{shellCmd}`
	puts "sysout=#{sysout}" if $VERBOSE
	return sysout
end
def self.plot(x,y)
	eval_R_shell("png(filename = \"#{tableName}.png\",width = 480, height = 480, units = \"px\", pointsize = 12, bg = \"white\",  res = NA,type = c(\"cairo\", \"Xlib\", \"cairo1\", \"quartz\"))")
	eval_R_shell("plot(#{x},#{y})")
	eval_R_shell("dev.off()")
end
def self.variableSummary(var)
	puts "#{var} "
	puts eval_R_shell("class(#{var})")
	puts eval_R_shell("summary(#{var})")
end
def self.pairSummary(x,y)
	variableSummary(x)
	variableSummary(y)
	plot(x,y)
end

end # R_Interface module
