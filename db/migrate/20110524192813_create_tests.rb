class CreateTests < ActiveRecord::Migration
  def self.up
    create_table :tests do |t|
      t.string :model
      t.string :test
      t.string :test_type
      t.string :environment
      t.integer :tests
      t.integer :assertions
      t.integer :failures
      t.integer :errors

      t.timestamps
    end
  end

  def self.down
    drop_table :tests
  end
end
