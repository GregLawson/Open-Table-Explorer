class Host < ActiveRecord::Base
include Generic_Table
has_many :ports
end
