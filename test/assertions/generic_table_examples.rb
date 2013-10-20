###########################################################################
#    Copyright (C) 2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
module OpenTableExplorer
module OpenTableBrowser
module Examples
class TestTable < ActiveRecord::Base
include DefaultAssertions
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
include DefaultAssertions
include Generic_Table
belongs_to :test_table
end #TestTable
class HalfAssociatedModel < ActiveRecord::Base
include DefaultAssertions
include Generic_Table
belongs_to :test_table
end #HalfAssociatedModel
class GenericTableAssociatedModel < ActiveRecord::Base
include DefaultAssertions
include Generic_Table
end #class
class EmptyAssociatedModel < ActiveRecord::Base
include DefaultAssertions
end #class
class EmptyClass
end #GenericTableAssociatedModel

class TestClass
include DefaultAssertions
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
end #TestClass
end #Examples
end #OpenTableBrowser
# Favorite test case for associations
class GenericTableExamples
@@CLASS_WITH_FOREIGN_KEY=StreamPatternArgument
@@FOREIGN_KEY_ASSOCIATION_CLASS=StreamPattern
@@FOREIGN_KEY_ASSOCIATION_SYMBOL=:stream_pattern # needs correct plurality
@@FOREIGN_KEY_ASSOCIATION_INSTANCE=@@FOREIGN_KEY_ASSOCIATION_CLASS.where(:name => 'Acquisition').first
@@TABLE_NAME_WITH_FOREIGN_KEY=@@CLASS_WITH_FOREIGN_KEY.name.tableize
end #GenericTableExamples
end #OpenTableExplorer