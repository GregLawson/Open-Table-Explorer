require 'test/test_helper'
class ArelReadmeTest < ActiveSupport::TestCase
def test_arel_readme_example #1
	users = Table(:users)
	users.to_sql
end #test
def test_arel_readme_example #1 correction attempt
	users = Arel::Table.new(:users)
	users.to_sql
end #test
end #class