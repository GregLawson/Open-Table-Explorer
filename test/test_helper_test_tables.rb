class TestTable < ActiveRecord::Base
include Generic_Table
has_many :full_associated_models
has_many :acquisition_stream_specs
belongs_to :frequency
has_many :acquisitions
belongs_to :fake_belongs_to
has_many :fake_has_many
has_and_belongs_to_many :fake_has_and_belongs_to_many
has_one :fake_has_one
def attribute_names
	return ['foreign_key_id'] 
end #def
end #class
class FullAssociatedModel < ActiveRecord::Base
include Generic_Table
belongs_to :test_table
end #class
class HalfAssociatedModel < ActiveRecord::Base
include Generic_Table
belongs_to :test_table
end #class
class GenericTableAssociatedModel < ActiveRecord::Base
include Generic_Table
end #class
class EmptyAssociatedModel < ActiveRecord::Base
end #class
class EmptyClass
end #class

class TestClass
def self.classMethod
end #def
public
def publicInstanceMethod
end #def
protected
def protectedInstanceMethod
end #def
private
def privateInstanceMethod
end #def
end #class
# Favorite test case for associations
@@CLASS_WITH_FOREIGN_KEY=StreamPatternArgument
@@FOREIGN_KEY_ASSOCIATION_CLASS=StreamPattern
@@FOREIGN_KEY_ASSOCIATION_SYMBOL=:stream_pattern # needs correct plurality
@@FOREIGN_KEY_ASSOCIATION_INSTANCE=@@FOREIGN_KEY_ASSOCIATION_CLASS.where(:name => 'Acquisition').first
@@TABLE_NAME_WITH_FOREIGN_KEY=@@CLASS_WITH_FOREIGN_KEY.name.tableize
