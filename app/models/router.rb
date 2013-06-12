require_relative 'no_db.rb'
class Router < ActiveRecord::Base

belongs_to :hosts
end
