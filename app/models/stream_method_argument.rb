class StreamMethodArgument < ActiveRecord::Base # like the arguments of a methed def
include Generic_Table
has_many :arguments, :polymorphic => true
end #class
