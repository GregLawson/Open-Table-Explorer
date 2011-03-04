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

class Acquisition_Stream_Spec < ActiveRecord::Base
include Generic_Table
belongs_to :table_spec, :class_name => "Table_spec"
validates_format_of :acquisition_interface, :with => /\A[a-zA-Z]{4,5}_Acquisition\z/,
    :message => "Only four or five letter mode followed by '_Acquisition' allowed."
def after_initialize
	@classReference= Generic_Table.classReference(self[:acquisition_interface])
	#~ @objectReference=@classReference.create(:url => self[:url])
end
def URI(component)
	self[:uri].select(component)
end #end
def parsedURI
	return URI.split(URI.escape(self[:url]))
end #def
def scheme
	return @URI.scheme
end #def
def schemelessUrl
	return URI.unescape(URI.escape(self[:url]).split(':').last)
end #def
def Acquisition_Stream_Spec.urls(model_class_name)
	return Acquisition_Stream_Spec.all(:order => "id",:conditions =>{:model_class_name=>model_class_name}).collect { |m| m.url }
end #def
def acquire
	#~ @objectReference.acquire
end #def
end
