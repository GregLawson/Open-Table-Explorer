class Node < ActiveRecord::Base
include Generic_Table
belongs_to :branch , :polymorphic => true
belongs_to :parent , :polymorphic => true
end #class
