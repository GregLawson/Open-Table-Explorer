class Host < ActiveRecord::Base
include Generic_Table
has_many :ports
has_many :routers
end
