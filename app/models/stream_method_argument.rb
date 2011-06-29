class StreamMethodArgument < ActiveRecord::Base # like the arguments of a methed def
has_many :arguments, :polymorphic => true
end #class
