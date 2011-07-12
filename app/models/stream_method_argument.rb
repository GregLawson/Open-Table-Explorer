class StreamMethodArgument < ActiveRecord::Base # like the arguments of a methed def
include Generic_Table
belongs_to :parameter , :polymorphic => true
end #class
