class Ofx < ActiveRecord::Base
include Generic_Table
belongs_to :accounts
belongs_to :parent , :polymorphic => true
end #class
