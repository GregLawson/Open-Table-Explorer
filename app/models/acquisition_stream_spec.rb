module Generic_Table
def Generic_Table.rubyClassName(model_class_name)
	model_class_name=model_class_name[0,1].upcase+model_class_name[1,model_class_name.length-1] # ruby class names are constants and must start with a capital letter.
	# remainng case is unchanged to allow camel casing to separate words for model names.
	return model_class_name
end #def
def Generic_Table.classDefiniton(model_class_name)
	return "class #{Generic_Table.rubyClassName(model_class_name)}  < ActiveRecord::Base\ninclude Generic_Table\nend"
end #def
def Generic_Table.classReference(model_class_name)
	rubyClassName=Generic_Table.rubyClassName(model_class_name)
	model_class_eval=eval("#{classDefiniton(rubyClassName)}\n#{rubyClassName}")
	return model_class_eval
end #def
end # module

class AcquisitionStreamSpec < ActiveRecord::Base
attr_reader :uri
include Generic_Table
belongs_to :table_spec, :class_name => "Table_spec"
validates_format_of :acquisition_interface, :with => /\A[a-zA-Z]{4,5}_Acquisition\z/,
    :message => "Only four or five letter mode followed by '_Acquisition' allowed."
def after_initialize
	@uri=URI.parse(URI.escape(self[:url]))	
	@classReference= Generic_Table.classReference(self[:acquisition_interface])
	#~ @objectReference=@classReference.create(:url => self[:url])
end
def uriComponent(componentName)
	ret=@uri.select(componentName)
	if ret.class==Array then
		return ret.class.name
	else
		return ret
	end
end #end
def uriArray
	return URI.split(URI.escape(self[:url]))
end #def
def uriHash
	componentNames=@uri.class::COMPONENT
	hash={}
	componentNames.each_index do |i| 
		componentName= componentNames[i] 
		component=uriComponent(componentName)
		if !component[0].nil? then
			hash.merge!({ componentName => component })
		end #if
	end # each_index
	return hash
end #def
def scheme
	return @uri.scheme
end #def
def schemelessUrl
	return URI.unescape(URI.escape(self[:url]).split(':').last)
end #def
def AcquisitionStreamSpec.urls(model_class_name)
	return AcquisitionStreamSpec.all(:order => "id",:conditions =>{:model_class_name=>model_class_name}).collect { |m| m.url }
end #def
def nameFromInterface
	self[:acquisition_interface][/([^_]*)_/, 1] 
end #def
def schemeFromInterface
	nameFromInterface.downcase
end #def
def consistantSchemes
	return scheme==schemeFromInterface
end #def
def acquire
	#~ @objectReference.acquire
end #def
end
