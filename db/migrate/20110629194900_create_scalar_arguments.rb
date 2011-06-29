class CreateScalarArguments < ActiveRecord::Migration
  def self.up
    create_table :scalar_arguments do |t|
      t.integer :id
      t.string :name
      t.string :value
      t.string :formula
      t.string :ruby_type

      t.timestamps
    end
  end

  def self.down
    drop_table :scalar_arguments
  end
end
