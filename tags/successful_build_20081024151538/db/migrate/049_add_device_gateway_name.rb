class AddDeviceGatewayName < ActiveRecord::Migration
  def self.up
    add_column :devices,:gateway_name,:string
    
    execute "update devices set gateway_name = 'xirgo'"
  end

  def self.down
    remove_column :devices,:gateway_name
  end
end
