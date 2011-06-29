class CreateStreamParameters < ActiveRecord::Migration
  def self.up
    create_table :stream_parameters do |t|
      t.integer :id
      t.integer :stream_method_call_id
      t.integer :stream_method_argument_id

      t.timestamps
    end
  end

  def self.down
    drop_table :stream_parameters
  end
end
