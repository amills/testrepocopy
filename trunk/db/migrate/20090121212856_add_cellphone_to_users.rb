class AddCellphoneToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :cellphone, :integer
  end

  def self.down
    remove_column :users, :cellphone
  end
end
