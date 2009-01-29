class AddStaticDeviceColumns < ActiveRecord::Migration
  def self.up
	  add_column :devices, :static_device, :boolean, :default => false
	  add_column :devices, :longitude, :decimal, :precision => 15, :scale => 10
	  add_column :devices, :latitude, :decimal, :precision => 15, :scale => 10
	  add_column :devices, :address, :string
	  end

  def self.down
	  remove_column :devices, :static_device
	  remove_column :devices, :latitude
	  remove_column :devices, :longitude
	  remove_column :devices, :address
	  end
end
