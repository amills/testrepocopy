class LengthenPhoneNumberColumnForDevices < ActiveRecord::Migration
  def self.up
    change_column :devices, :phone_number, :string, :limit => 100
  end

  def self.down
    change_column :devices, :phone_number, :string, :limit => 20
  end
end
