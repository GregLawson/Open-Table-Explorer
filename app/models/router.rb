class Router < ActiveRecord::Base
include Generic_Table
belongs_to :hosts
end
