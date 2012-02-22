class Node < ActiveRecord::Base
include Generic_Table
belongs_to :branch , :polymorphic => true
belongs_to :parent , :polymorphic => true
def self.logical_primary_key
	return [:id]
end #logical_primary_key
end #class
