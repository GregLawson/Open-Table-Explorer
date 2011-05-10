require 'test_helper'
class ArelReadmeTest < ActiveSupport::TestCase
test "arel readme example #1" do
	users = Table(:users)
	users.to_sql
end #test
test "arel readme example #1 correction attempt" do
	users = Arel::Table.new(:users)
	users.to_sql
end #test
end #class