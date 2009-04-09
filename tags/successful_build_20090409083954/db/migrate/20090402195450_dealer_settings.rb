class DealerSettings < ActiveRecord::Migration
  def self.up
    add_column :accounts,:dealer,:boolean,:null => false,:default => true
    add_column :devices,:dealer,:boolean,:null => false,:default => true
  end

  def self.down
    remove_column :accounts,:dealer
    remove_column :devices,:dealer
  end
end
