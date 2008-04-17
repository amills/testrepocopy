class AddIoColumnsToReadings < ActiveRecord::Migration
  def self.up
    add_column :readings, :transmission_gear, :string, :limit => 25
    add_column :readings, :odometer, :float
    add_column :readings, :fuel_rate, :string
  end

  def self.down
    remove_column :readings, :transmission_gear
    remove_column :readings, :odometer
    remove_column :readings, :fuel_rate
  end
end
