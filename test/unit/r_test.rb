require_relative 'test_environment'
require_relative 'default_test_case.rb'
require_relative "../../app/models/r.rb"
require 'rserve'
class RSessionTest <TestCase
include DefaultTests1
include RSession::Constants
include DataFrames::Examples
def test_initialize

end #initialize
def test_eval
	rexp=Default_Session.eval('1+1')
	assert_equal([2.0], rexp.as_doubles)
end #eval
def test_example
	con=RSession.new
	x=con.eval('x<-rnorm(1)')
	assert_instance_of(Rserve::REXP::Double, x)
	x=con.eval('1+1')
	assert_equal([2.0], x.as_doubles)
	assert_equal(["2.0"], x.as_strings)
        assert_instance_of(Float, x.to_ruby)
	assert_equal(2.0, x.to_ruby)
 
	x=con.eval('list(l1=list(c(2,3)),l2=c(1,2,3))').to_ruby
	assert_instance_of(Array, x)
	assert_instance_of(Array, x[0])
	assert_instance_of(Array, x[0][0])
#<Array:19590368 [#<Array:19590116 [[(2/1), (3/1)]] names:nil>, [(1/1), (2/1), (3/1)]] names:["l1", "l2"]>

    
    # You could assign a REXP to R variables

    con.assign("x", Rserve::REXP::Double.new([1.5,2.3,5]))
#<Rserve::Packet:0x0000000136b068 @cmd=65537, @cont=nil>
    con.eval("x")
#<Rserve::REXP::Double:0x0000000134e770 @payload=[(3/2), (2589569785738035/1125899906842624), (5/1)], @attr=nil>
    
    # Rserve::REXP::Wrapper.wrap allows you to transform Ruby object to 
    # REXP, could be assigned to R variables
    
    Rserve::REXP::Wrapper.wrap(["a","b",["c","d"]])
    
    #<Rserve::REXP::GenericVector:0x000000010c81d0 @attr=nil, @payload=#<Rserve::Rlist:0x000000010c8278 @names=nil, @data=[#<Rserve::REXP::String:0x000000010c86d8 @payload=["a"], @attr=nil>, #<Rserve::REXP::String:0x000000010c85c0 @payload=["b"], @attr=nil>, #<Rserve::REXP::String:0x000000010c82e8 @payload=["c", "d"], @attr=nil>]>>

end #example
def test_csv_import
	Loopback.csv_import([:ain,:aout_value], Loopback_Filename)
end #csv_import
def test_r_symbol
	assert_equal("loopback$V8", Loopback.r_symbol(:V8))	
end #r_symbol
def test_r_class_symbol
	var='loopback$V8'
	klass=Default_Session.eval("class(#{var})")
	assert_equal("integer", klass.as_strings[0])	
	assert_equal("integer", Loopback.r_class_symbol(:V8))	
end #r_class_symbol
def test_variableSummary
	var=:V8
	summary=Default_Session.eval("summary(#{var})").as_doubles
	assert_instance_of(Array, summary)	
	assert_equal("", Loopback.variableSummary(:V9))	
end #variableSummary
def test_pairSummary
end #pairSummary
def test_loopback
	con=RSession.new


	con.eval("loopback<-read.table('/tmp/loopback4.csv',sep=',',fill=TRUE)")
	con.eval("ain<-as.factor(loopback$V10)")


	puts con.eval("tapply(loopback$V10,ain,summary)")
	con.eval("rle(as.vector(ain))")
	df=DataFrames.new(:loopback)
	df.pairSummary('loopback$V9','loopback$V10')
end #test_loopback
end #RSessionTest
