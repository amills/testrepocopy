class AddHorizontalAccuracyToReadings < ActiveRecord::Migration
  def self.up
    add_column :readings, :horizontal_accuracy, :float
  end

  def self.down
    remove_column :readings, :horizontal_accuracy
  end
end