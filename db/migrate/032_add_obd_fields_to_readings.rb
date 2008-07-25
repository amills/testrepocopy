class AddObdFieldsToReadings < ActiveRecord::Migration
  def self.up
    add_column :readings, :vehicle_speed, :float
    add_column :readings, :engine_speed, :float
    add_column :readings, :fuel_level_remaining, :float
    add_column :readings, :battery_voltage, :float
    add_column :readings, :trip_odometer, :integer
    add_column :readings, :trip_fuel_consumption, :float
  end

  def self.down
    remove_column :readings, :vehicle_speed
    remove_column :readings, :engine_speed
    remove_column :readings, :fuel_level_remaining
    remove_column :readings, :battery_voltage
    remove_column :readings, :trip_odometer
    remove_column :readings, :trip_fuel_consumption
  end
end
