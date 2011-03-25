class Transfer < ActiveRecord::Base
belongs_to :account
include Global
end
