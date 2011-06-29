class CreateStreamMethods < ActiveRecord::Migration
  def self.up
    create_table :stream_methods do |t|
      t.string :name
      t.string :library
      t.text :interface_code
      t.text :return_code
      t.text :rescue_code

      t.timestamps
    end
  end

  def self.down
    drop_table :stream_methods
  end
end
