class BreakoutAddress < ActiveRecord::Migration
  def self.up
    execute "ALTER TABLE `readings` ADD COLUMN `geocoded` tinyint(1) NOT NULL default '0', ADD COLUMN `street_number` varchar(255), ADD COLUMN `street` varchar(255), ADD COLUMN `place_name` varchar(255), ADD COLUMN `admin_name1` varchar(255)"
  end

  def self.down
    execute "ALTER TABLE `readings` DROP COLUMN `geocoded`, DROP COLUMN `street_number`, DROP COLUMN `street`, DROP COLUMN `place_name`, DROP COLUMN `admin_name1`"
  end
end
