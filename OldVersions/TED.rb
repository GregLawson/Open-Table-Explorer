#   Copyright (C) 2009  Gregory Lawson
#  
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU Lesser General Public License as published by
#   the Free Software Foundation; either version 2.1 of the License, or
#   (at your option) any later version.
# 
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU Lesser General Public License for more details.
# 
#   You should have received a copy of the GNU Lesser General Public License
#   along with this program; if not, a copy is available at
#   http://www.gnu.org/licenses/gpl-2.0.html
class TED  < Table
include XML_Acquisition
@@MAX_PRODUCTION=3500
@@MAX_CONSUMPTION=2000
@@MIN_CONSUMPTION=3
@@MAX_TED=@@MAX_PRODUCTION-@@MIN_CONSUMPTION
@@MAX_VOLTAGE=1300
@@MIN_VOLTAGE=1000
@@OUTLIER_EXTREME_VALUE_BITS=12
@@OUTLIER_DUP_CHECK_BITS=3
@@OUTLIER_NO_CHANGE_BITS=6
@@OUTLIER_EXTREME_VALUE_BIT=@@OUTLIER_NO_CHANGE_BITS+@@OUTLIER_DUP_CHECK_BITS
@@OUTLIER_DUP_CHECK_BIT=@@OUTLIER_NO_CHANGE_BITS
@@OUTLIER_NO_CHANGE_BIT=0
@@REJECT_THRESHOLD=2**(@@OUTLIER_NO_CHANGE_BITS+@@OUTLIER_DUP_CHECK_BITS)
@@MAX_NOCHANGE_LENGTH=7
@@MIN_NOISE=3
@@MAX_SLEEP_INTERVAL=10

def initialize
errorMessage=DB.execute("DROP view tedprimaries_ip;create view tedprimaries_ip as select INET '192.168.3.193' as ip where otherports>=1713 and otherstate='filtered';","ERROR:  relation \"tedprimaries_ip\" already exists")
super('tedprimaries','id')
getIP
@frozen=false
@thawLength=0
@freezeLength=0
@previousThaw=0
@previousFreeze=0
@sleepInterval=@@MAX_SLEEP_INTERVAL/2.0
@previous={}
@freezeDisplay=0
@TOO_SHORT_SLEEP_INTERVAL=0
@TOO_LONG_SLEEP_INTERVAL=@@MAX_SLEEP_INTERVAL
end
def plausible_values(ted)
	outlier=0 # assume fine until proven different
	#puts "before  plausible_values"
	if ted["total_powernow"].to_s.to_f>@@MAX_TED then
		outlier=2**(@@OUTLIER_EXTREME_VALUE_BIT)
	end
	if ted["mtu1_powernow"].to_s.to_f>@@MAX_TED then
		outlier=outlier+2**(@@OUTLIER_EXTREME_VALUE_BIT+1)
	end
	if ted["total_kva"].to_s.to_f<0 then
		outlier=outlier+2**(@@OUTLIER_EXTREME_VALUE_BIT+2)
	end
	if ted["mtu1_kva"].to_s.to_f<0 then
		outlier=outlier+2**(@@OUTLIER_EXTREME_VALUE_BIT+3)
	end
	if ted["total_kva"].to_s.to_f>@@MAX_TED then
		outlier=outlier+2**(@@OUTLIER_EXTREME_VALUE_BIT+4)
	end
	if ted["mtu1_kva"].to_s.to_f>@@MAX_TED then
		outlier=outlier+2**(@@OUTLIER_EXTREME_VALUE_BIT+5)
	end
	if ted["total_voltagenow"].to_s.to_f>@@MAX_VOLTAGE then
		outlier=outlier+2**(@@OUTLIER_EXTREME_VALUE_BIT+6)
	end
	if ted["mtu1_voltagenow"].to_s.to_f>@@MAX_VOLTAGE then
		outlier=outlier+2**(@@OUTLIER_EXTREME_VALUE_BIT+7)
	end
	if ted["total_voltagenow"].to_s.to_f<@@MIN_VOLTAGE then
		outlier=outlier+2**(@@OUTLIER_EXTREME_VALUE_BIT+8)
	end
	if ted["mtu1_voltagenow"].to_s.to_f<@@MIN_VOLTAGE then
		outlier=outlier+2**(@@OUTLIER_EXTREME_VALUE_BIT+9)
	end
	if ted["total_powernow"].to_s.to_f > ted["total_kva"].to_s.to_f then
		outlier=outlier+2**(@@OUTLIER_EXTREME_VALUE_BIT+10)
	end
	if ted["mtu1_powernow"].to_s.to_f > ted["mtu1_kva"].to_s.to_f then
		outlier=outlier+2**(@@OUTLIER_EXTREME_VALUE_BIT+11)
	end
	return outlier
end
def dup_check(ted)
	#puts "before  dup_check"
	outlier=0 # assume fine until proven different
	if ted["total_powernow"].to_i!=ted["mtu1_powernow"].to_i then
		outlier=outlier+2**(@@OUTLIER_DUP_CHECK_BIT)
	end
	if ted["total_kva"].to_i!= ted["mtu1_kva"].to_i then
		outlier=outlier+2**(@@OUTLIER_DUP_CHECK_BIT+1)
	end
	if ted["total_voltagenow"].to_i!=ted["mtu1_voltagenow"].to_i then
		outlier=outlier+2**(@@OUTLIER_DUP_CHECK_BIT+2)
	end
	return outlier
end
def no_change(previous,current)
	#puts "before  no_change"
	outlier=0 # assume fine until proven different
	if previous["total_voltagenow"].to_i==current["total_voltagenow"].to_i then
		outlier=outlier+2**(@@OUTLIER_NO_CHANGE_BIT)
	end
	if previous["mtu1_voltagenow"].to_i==current["mtu1_voltagenow"].to_i then
		outlier=outlier+2**(@@OUTLIER_NO_CHANGE_BIT+1)
	end
	if previous["total_kva"].to_i== current["total_kva"].to_i then
		outlier=outlier+2**(@@OUTLIER_NO_CHANGE_BIT+2)
	end
	if previous["mtu1_kva"].to_i== current["mtu1_kva"].to_i then
		outlier=outlier+2**(@@OUTLIER_NO_CHANGE_BIT+3)
	end
	if previous["total_powernow"].to_i==current["total_powernow"].to_i then
		outlier=outlier+2**(@@OUTLIER_NO_CHANGE_BIT+4)
	end
	if previous["mtu1_powernow"].to_i==current["mtu1_powernow"].to_i then
		outlier=outlier+2**(@@OUTLIER_NO_CHANGE_BIT+5)
	end
	return outlier
end
def outlierString(outlier)
	str=' %07o'%outlier
	return   str.tr('0','-')
end
def explainOutlier
	if plausible_values(@data) != 0 then
		#puts "plausible_values(@data)=#{' %07o'%outlierString(plausible_values(@data))}"
		if @data["total_powernow"].to_s.to_f>@@MAX_TED then
			#puts "@data['total_powernow'].to_s.to_f=#{@data['total_powernow'].to_s.to_f}"
			#puts "@data['total_powernow'].to_s.to_f > @@MAX_TED"
			#print "outlier=" ," %07o"%@data["outlier"]
			#puts "plausible_values(@data)=#{' %07o'%outlierString(plausible_values(@data))}"
			if (@data["total_powernow"].to_s.to_i&0x0000C000)==0 then
				print "@data['total_powernow'].to_s.to_i&0x00000FFF =#{@data['total_powernow'].to_s.to_i&0x00000FFF}\n"
			else
				print "@data['total_powernow'].to_s.to_i|0xFFFFF000 =#{~(@data['total_powernow'].to_s.to_i)&0x00000FFF}\n"
			end 
		end
		if @data["mtu1_powernow"].to_s.to_f>@@MAX_TED then
			puts "@data['mtu1_powernow'].to_s.to_f=#{@data['mtu1_powernow'].to_s.to_f}"
		end
		if @data["total_kva"].to_s.to_f>@@MAX_TED then
			puts "@data['total_kva'].to_s.to_f=#{@data['total_kva'].to_s.to_f}"
			#puts "@data['total_kva'].to_s.to_i > @@MAX_TED"
			#print "outlier=" ," %07o"%@data["outlier"]
			#puts "plausible_values(@data)=#{' %07o'%plausible_values(@data)}"
			if (@data["total_kva"].to_s.to_i&0x0000C000)==0 then
				print "@data['total_kva'].to_s.to_i&0x00000FFF =#{@data['total_kva'].to_s.to_i&0x00000FFF}\n"
			else
				print "@data['total_kva'].to_s.to_i|0xFFFFF000 =#{~(@data['total_kva'].to_s.to_i)&0x00000FFF}\n"
			end 
		end
		if @data["mtu1_kva"].to_s.to_f<0 then
			puts "@data['mtu1_kva'].to_s.to_f=#{@data['mtu1_kva'].to_s.to_f}"
		end
		if @data["total_kva"].to_s.to_f>@@MAX_TED then
			puts "@data['total_kva'].to_s.to_f=#{@data['total_kva'].to_s.to_f}"
		end
		if @data["mtu1_kva"].to_s.to_f>@@MAX_TED then
			puts "@data['mtu1_kva'].to_s.to_f=#{@data['mtu1_kva'].to_s.to_f}"
		end
		if @data["total_voltagenow"].to_s.to_f>@@MAX_VOLTAGE then
			puts "@data['total_voltagenow'].to_s.to_f=#{@data['total_voltagenow'].to_s.to_f}"
		end
		if @data["mtu1_voltagenow"].to_s.to_f>@@MAX_VOLTAGE then
			puts "@data['mtu1_voltagenow'].to_s.to_f=#{@data['mtu1_voltagenow'].to_s.to_f}"
		end
		if @data["total_voltagenow"].to_s.to_f<@@MIN_VOLTAGE then
			puts "@data['total_voltagenow'].to_s.to_f=#{@data['total_voltagenow'].to_s.to_f}"
		end
		if @data["mtu1_voltagenow"].to_s.to_f<@@MIN_VOLTAGE then
			puts "@data['mtu1_voltagenow'].to_s.to_f=#{@data['mtu1_voltagenow'].to_s.to_f}"
		end
	end
	if  @data["total_powernow"].to_s.to_f/@data["total_kva"].to_s.to_f>1 then
		puts "@data['total_powernow'].to_s.to_f/@data['total_kva'].to_s.to_f=#{@data['total_powernow'].to_s.to_f/@data['total_kva'].to_s.to_f}"
	end
	if @data["total_powernow"].to_s.to_f > @data["total_kva"].to_s.to_f then
		puts "@data['total_powernow']=\"#{@data['total_powernow']}\"!=@data['total_kva']=\"#{@data['total_kva']}\""
	end
	if @data["mtu1_powernow"].to_s.to_f > @data["mtu1_kva"].to_s.to_f then
		puts "@data['mtu1_powernow']=\"#{@data['mtu1_powernow']}\"!=@data['mtu1_kva']=\"#{@data['mtu1_kva']}\""
	end
	if dup_check(@data) != 0 then
		puts "dup_check(@data)=#{' %07o'%dup_check(@data)}"
		if @data["total_powernow"].to_i!=@data["mtu1_powernow"].to_i then
			puts "@data['total_powernow']=\"#{@data['total_powernow']}\"!=@data['mtu1_powernow']=\"#{@data['mtu1_powernow']}\""
		end
		if @data["total_kva"].to_i!= @data["mtu1_kva"].to_i then
			puts "@data['total_kva']=\"#{@data['total_kva']}\"!=@data['mtu1_kva']=\"#{@data['mtu1_kva']}\""
		end
		if @data["total_voltagenow"].to_i!=@data["mtu1_voltagenow"].to_i then
			puts "@data['total_voltagenow']=\"#{@data['total_voltagenow']}\"!=@data['mtu1_voltagenow']=\"#{@data['mtu1_voltagenow']}\""
		end
	end
end
def checkFreeze(outlier)
if (outlier & 0b111111) == 0b111111 then
	if @frozen then
		@freezeLength+=1
	else
		@frozen=true
		@previousFreeze=@freezeLength
		@freezeLength=1
	end
else
	if @frozen then
		@frozen=false
		@previousThaw=@thawLength	
		@thawLength=1
	else
		@thawLength+=1
	end
end
return @freezeLength
end
def freezeMetric
	if @freezeLength > @previousFreeze then
		if @thawLength > @previousThaw
			return @freezeLength/(@freezeLength+@thawLength)
		else
			return @freezeLength/(@freezeLength+@previousThaw)
		end
	else
		if @thawLength > @previousThaw
			return @previousFreeze/(@previousFreeze+@thawLength)
		else
			return @previousFreeze/(@previousFreeze+@previousThaw)
		end
	end
end
def acquire
	@page=getXML("http://#{@IP}/api/LiveData.xml")
	names,values = xmlParse('LiveData/GatewayTime/*')
	names.each_index do |i|
		update_attribute(names[i].downcase,values[i])
	end
	names=[]
	values=[]
	@doc.elements.each('LiveData/*/*[name()="Total" or name()="MTU1"]/*[name()="KVA" or contains(name(),"Now")]') do |s|
		#puts "s=#{s}"
		attrName="#{s.parent.name.downcase}_#{s.name.downcase}"
		names.push(attrName)
		values.push(s[0].to_s)
	end
	#puts "names=#{names}"
	#puts "values=#{values}"
	names.each_index do |i|
		update_attribute(names[i],values[i])
	end
	now=Time.now
	update_attribute("created_at",now)
	update_attribute("updated_at",now)
	#dump(@sqlValues)
end
def noiseFloored(noise)
	if noise<@@MIN_NOISE**2 then # quantization noise doesn't average out
		return @@MIN_NOISE**2 # guess minimum noise
	elsif noise > @@MAX_TED **2then
		return @@MAX_TED**2
	else
		return noise
	end
end
def fixup(value)
	#puts "value=#{value}"
	if (value&0x0000C000)==0 then
		fixed= value&0x00000FFF
		#puts "value&0x00000FFF=#{fixed}"
	else
		fixed= ~(value)&0x00000FFF
		#puts " ~(value)&0x00000FFF=#{fixed}"
	end
	return fixed
end
def computeConsumption
	#explainOutlier
	if @previous.empty? then
		@data["noise"]=@@MIN_NOISE # guess
	else	
		if @freezeLength==1 and @previousFreeze!=0 then
			@data["noise"]=@previous["noise"].to_f/Math::sqrt(@previousFreeze) # undo freeze drift
		else
			#@data["noise"]=Math::sqrt(@previous["noise"].to_f/@previous.fetch("prediction_samples",1))
			#print "@previous['noise'].to_f=#{@previous['noise'].to_f}"
			#puts "@previous.fetch('prediction_samples',1))=#{@previous.fetch('prediction_samples',1)}"
		end
	end
	@data["noise"]= noiseFloored(@data["noise"])	
	if @data["total_powernow"].to_i>@@MAX_TED or @data["total_powernow"].to_i<0 then
		if @data["mtu1_powernow"].to_i>@@MAX_TED or @data["mtu1_powernow"].to_i<0 then
			@consumption = fixup(@data["mtu1_powernow"].to_i)
			#puts "fixup(@data['mtu1_powernow'].to_i)=#{fixup(@data['mtu1_powernow'].to_i)}"
			#puts "@consumption=#{@consumption}"
		else
			@consumption = @data["mtu1_powernow"].to_i
		end
	else
		@consumption = @data["total_powernow"].to_i
	end
		#puts "@data['total_kva'].to_i=#{@data['total_kva'].to_i}"
		#puts "@@MAX_TED=#{@@MAX_TED}"
	#puts "@data['total_kva'].to_i>@@MAX_TED=#{(@data['total_kva'].to_i)>@@MAX_TED}"
	#puts "@data['total_kva'].to_i>3497=#{(@data['total_kva'].to_i)>3497}"
	#puts "@data['total_kva'].to_i>@@MAX_TED=#{(@data['total_kva'].to_i)>@@MAX_TED}"
	if @data["total_kva"].to_i>@@MAX_TED or @data["total_kva"].to_i<0 then
		if @data["mtu1_kva"].to_i>@@MAX_TED or @data["mtu1_kva"].to_i<0 then
			reactivePower = fixup(@data["mtu1_kva"].to_i) -@consumption
			#puts "fixup(@data['mtu1_kva'].to_i)=#{fixup(@data['mtu1_kva'].to_i)}"
		else
			reactivePower = (@data['mtu1_kva'].to_i)  -@consumption
			#puts "@data['mtu1_kva'].to_i=#{@data['mtu1_kva'].to_i}"
		end
	else
		#puts "@data['total_kva'].to_i=#{@data['total_kva'].to_i}"
		#puts "@consumption=#{@consumption}"
		reactivePower = (@data["total_kva"].to_i)  -@consumption
	end
	#puts "@consumption=#{@consumption},reactivePower=#{reactivePower},@data['noise']=#{@data['noise']}"
	return [@consumption,reactivePower,@data["noise"]]
end
def compute
	#puts "@data['total_powernow']=#{@data['total_powernow']}"
	#puts "@data['production'].to_s.to_f=#{@data['production'].to_s.to_f}"
	if @previous.empty? then
		@period=0	
	else	
		@period=Time.now-@prevTime
	end
	#puts "after period=#{@period}"
	#puts "before outlier"
	@qualityCheck = plausible_values(@data)+dup_check(@data)
	@data["outlier"]=plausible_values(@data)+dup_check(@data)+no_change(@previous,@data)
	if @data["outlier"].to_i&0x3F == 0x3F then # no change
		@TOO_SHORT_SLEEP_INTERVAL=0.5*@sleepInterval+0.49*@TOO_SHORT_SLEEP_INTERVAL
		@sleepInterval=0.4*@TOO_SHORT_SLEEP_INTERVAL+0.6*@TOO_LONG_SLEEP_INTERVAL
		@TOO_LONG_SLEEP_INTERVAL=0.8*@TOO_LONG_SLEEP_INTERVAL+0.2*@@MAX_SLEEP_INTERVAL*@freezeLength
	elsif @previous.empty?
	else
		@TOO_LONG_SLEEP_INTERVAL=@sleepInterval/@thawLength
		@sleepInterval=0.8*@TOO_SHORT_SLEEP_INTERVAL+0.2*@TOO_LONG_SLEEP_INTERVAL
		@TOO_SHORT_SLEEP_INTERVAL=[@sleepInterval,@TOO_SHORT_SLEEP_INTERVAL,@@MAX_SLEEP_INTERVAL*@freezeLength].min
	end
	@data['change_interval']=@sleepInterval
	#puts "@data['outlier']&0x3F=#{@data['outlier']&0x3F}"
	#puts "@TOO_SHORT_SLEEP_INTERVAL=#{'%5.1f'%@TOO_SHORT_SLEEP_INTERVAL}"
	#puts "@sleepInterval=#{'%5.1f'%@sleepInterval}"
	#puts "@TOO_LONG_SLEEP_INTERVAL=#{'%5.1f'%@TOO_LONG_SLEEP_INTERVAL}"
	@consumption,reactivePower,@data["noise"]=computeConsumption
	@powerFactor=@consumption/(@consumption+reactivePower)
	#puts "@data['total_powernow']=#{@data['total_powernow']}"
	#puts "@data['production'].to_s.to_f=#{@data['production'].to_s.to_f}"
	if checkFreeze(@data["outlier"])<@@MAX_NOCHANGE_LENGTH and  @data["outlier"]<@@REJECT_THRESHOLD then
		#puts "@consumption=#{@consumption}"
		if @previous.empty? then
			#puts "@previous empty"	
			#puts "before predictionkva"
			@previous["prediction"]=@consumption # serial correlation guess
			puts "previous.empty @data['prediction']=#{@data['prediction']}" if $DEBUG
			#puts "before change"
			@change=@data["total_powernow"].to_s.to_f	
			#puts "before noise"
			@data["noise"]=@@MIN_NOISE # guess
			@data["prediction_samples"]=1
		else	
			#print "not first time @previous[\"prediction_samples\"]="
			#puts @previous["prediction_samples"]
			#puts "before change, prediction=#{@previous["prediction"]}"
	 		@change=@consumption-@previous["prediction"]
			#puts "before noise"
			if @freezeLength==1 and @previousFreeze!=0 then
				@data["noise"]=@previous["noise"].to_f/Math::sqrt(@previousFreeze) # undo freeze drift
				#puts "@previous['noise'].to_f=#{@previous['noise'].to_f} Math::sqrt(@previousFreeze)=#{Math::sqrt(@previousFreeze)} @change=#{@change}"
			else
				#@data["noise"]=Math::sqrt(@previous["noise"].to_f/@previous.fetch("prediction_samples",1))
				#print "@previous['noise'].to_f=#{@previous['noise'].to_f}"
				#puts "@previous.fetch('prediction_samples',1))=#{@previous.fetch('prediction_samples',1)}"
			end
		end
		@data["prediction_samples"]=@previous.fetch("prediction_samples",0)+1
		@alpha=1/(@data["prediction_samples"])	# first time alpha==1
		#puts "before prediction=#{@previous["prediction"]}"
 		@data["prediction"]=@alpha*@consumption+(1-@alpha)*@previous.fetch("prediction",0)
		#puts "common @data['prediction']=#{@data['prediction']}"
		#puts "after prediction=#{@data["prediction"]}"
 		@data["predict_reactive_power"]=@alpha*reactivePower+(1-@alpha)*@previous.fetch("predict_reactive_power",0)
		#puts "before switch check"
		@data["noise"]= noiseFloored(@data["noise"])
		if @change.abs>3*Math::sqrt(@data["noise"].to_f) and (@data['outlier'].to_i<63) then
			@data["prediction_samples"]=1
		 	@data["switched_state"]=@previous.fetch("switched_state",0)+1
			#puts "before switch age to zero"
		 	@data["switched_age"]=0
			@data["prediction"]=@consumption
			#puts "switched @data['prediction']=#{@data['prediction']}"
		 	@data["predictkva"]=@data["total_kva"].to_s.to_f
			@data["noise"]=@previous.fetch("noise",5.0) # do not include switch in noise statstics
		else
		 	@data["switched_state"]=@previous.fetch("switched_state",0)
			#puts "before switch age increment"
		 	@data["switched_age"]=@previous.fetch("switched_age",0).to_f+@period
			@data["noise"]=0.05*(@change**2)+(1-0.95)*@previous.fetch("noise",0.0).to_f
		end
 	else  # bad data
		#puts "checkFreeze(@data['outlier'])=#{checkFreeze(@data['outlier'])} < @@MAX_NOCHANGE_LENGTH=#{@@MAX_NOCHANGE_LENGTH} "
		#puts "@data['outlier']=#{@data['outlier']} < @@REJECT_THRESHOLD=#{@@REJECT_THRESHOLD}"
		@data["prediction_samples"]=@previous.fetch("prediction_samples",1)
		@data["switched_state"]=@previous.fetch("switched_state",0)
	 	@data["switched_age"]=@previous.fetch("switched_age",0.0).to_f+@period
		@data["prediction"]=@previous.fetch("prediction",@consumption)
		#puts "bad data @previous['prediction']=#{@previous['prediction']}"
		#puts "bad data @data['prediction']=#{@data['prediction']}"
		@data['predict_reactive_power']=@previous.fetch('predict_reactive_power',reactivePower)	
		if @freezeLength>1 then		
			@data["noise"]=@previous.fetch("noise",@@MIN_NOISE).to_f*Math::sqrt(@freezeLength)/Math::sqrt(@freezeLength-1) # estimate freeze drift
		else
			@data["noise"]=@previous.fetch("noise",@@MIN_NOISE).to_f
		end
		@change=0.0
	end
	@previous=@data
	@prevTime=Time.now
	@prevConsumption=@consumption
end
def printScan
	print outlierString(@data["outlier"])
	#print " %07o"%@data["outlier"]
	#print " ",@freezeLength," ",@thawLength," ",@previousFreeze," ",@previousThaw
	if @frozen and @freezeLength>@@MAX_NOCHANGE_LENGTH then
		print " f "
	else
		print " t "
	end
	@freezeDisplay=0.5*@freezeDisplay+0.5*freezeMetric
	#print freezeMetric
	print "%4.0f"%(100.0*@freezeDisplay)
	print " %5.1fs"%@sleepInterval
end
def printLog
	print "% 4dW"%@consumption
	print " ","% 4.1fW"%@data["prediction"]
	print " ","% 4.1fW"%Math::sqrt(@data["noise"])
	print " ","% 4d"%@data["switched_state"]
	print " ","%5d"%@data["prediction_samples"]
	#print " ","% 4dW"%@data["total_powernow"].to_s.to_f
	print " ","% 4dW"%@data["production"].to_s.to_f
	print "%5.1f%"%(100*@powerFactor)
	printScan
	#print "#{@data['outlier'].to_i<63},#{ @data["prediction_samples"]==1},#{@data["prediction_samples"]==1 and (@data['outlier'].to_i<63)}"
	if @data["prediction_samples"]==1 and (@data['outlier'].to_i<63) then
		print " %5.0fW"%@change
	end

end
def flooredSleepInterval
	if @sleepInterval> @@MAX_SLEEP_INTERVAL
		return @@MAX_SLEEP_INTERVAL
	else
		return @sleepInterval
	end
end
end
