class AddTripsToDeviceProfiles < ActiveRecord::Migration
  def self.up
    add_column :device_profiles, :trips, :boolean,:null => false, :default => false
    execute "update device_profiles set trips=1 where name='Fleet Plus'"
  end

  def self.down
    remove_column :device_profiles, :trips
  end
end
