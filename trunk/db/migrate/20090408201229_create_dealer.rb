class CreateDealer < ActiveRecord::Migration
  def self.up
    create_table :dealers do |t|
      t.column "name", :string, :default => ''
      t.column "is_deleted", :boolean, :default => false
    end
    
    create_table :dealers_users, :id => false do |t|
      t.column "dealer_id", :integer
      t.column "user_id", :integer
    end
    add_column :accounts, :dealer_id, :integer, :default => nil
    add_column :accounts, :is_dealer, :boolean, :default => false
    add_column :users, :is_super_super_admin, :boolean, :default => false
  end

  def self.down
    drop_table :dealers
    drop_table :dealers_users
    remove_column :accounts, :is_dealer
    remove_column :users, :is_super_super_admin
  end
end
