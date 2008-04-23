class AddTempHumidityAccelToReadings < ActiveRecord::Migration
  def self.up
    add_column :readings, :temp, :float
    add_column :readings, :humid_temp, :float
    add_column :readings, :humid_relative, :float
    add_column :readings, :humid_true, :float
    add_column :readings, :accel_xforce, :float
    add_column :readings, :accel_yforce, :float
    add_column :readings, :accel_xpitch, :float
    add_column :readings, :accel_yroll, :float
  end

  def self.down
    remove_column :readings, :temp
    remove_column :readings, :humid_temp
    remove_column :readings, :humid_relative
    remove_column :readings, :humid_true
    remove_column :readings, :accel_xforce
    remove_column :readings, :accel_yforce
    remove_column :readings, :accel_xpitch
    remove_column :readings, :accel_yroll
  end
end
