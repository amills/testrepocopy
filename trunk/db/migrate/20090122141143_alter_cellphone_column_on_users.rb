class AlterCellphoneColumnOnUsers < ActiveRecord::Migration
  def self.up
	  change_column :users, :cellphone, :string, :limit => 20
  end

  def self.down
	  change_column :users, :cellphone, :integer
  end
end
