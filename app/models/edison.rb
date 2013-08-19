class Edison < ActiveRecord::Base
include Generic_Table
has_many :tedprimaries
end
