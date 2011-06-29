class CreateStreamMethodArguments < ActiveRecord::Migration
  def self.up
    create_table :stream_method_arguments do |t|
      t.integer :id
      t.integer :stream_method_id
      t.string :name
      t.string :ruby_type
      t.string :direction
      t.integer :parameter_id
      t.string :parameter_type

      t.timestamps
    end
  end

  def self.down
    drop_table :stream_method_arguments
  end
end
