class CreateRubyInterfaces < ActiveRecord::Migration
  def self.up
    create_table :ruby_interfaces do |t|
      t.string :name
      t.string :library
      t.text :interface_code
      t.text :return_code
      t.text :rescue_code
      t.string :type

      t.timestamps
    end
  end

  def self.down
    drop_table :ruby_interfaces
  end
end
