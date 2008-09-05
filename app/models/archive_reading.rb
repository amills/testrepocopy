class ArchiveReading < ActiveRecord::Base
  
  def self.transfer_data_from_readings_to_archived_readings_table(number_of_days_back)      
      ninety_days_older_date = Date.today - number_of_days_back
      ninety_days_older_date = ninety_days_older_date.to_s + ' 00:00:00'
      readings_older_than_90_days = Reading.find(:all, :conditions=>['created_at < ?',ninety_days_older_date])      
      for reading in  readings_older_than_90_days
         if ArchiveReading.find_by_reading_id(reading.id).nil?
             archived_reading = ArchiveReading.new(:reading_id => reading.id, :latitude => reading.latitude, :longitude => reading.longitude,:altitude => reading.altitude,
                                  :speed => reading.speed, :direction => reading.direction,:device_id => reading.device_id, :event_type => reading.event_type,
                                  :note => reading.note, :address => reading.address, :notified=>reading.notified, :ignition=>reading.ignition,
                                  :gpio1 => reading.gpio1, :gpio2 => reading.gpio2, :created_at => reading.created_at, :updated_at => reading.updated_at                                 
                                )             
             if archived_reading.save
                 Reading.delete(reading.id)
             end    
         end    
      end
  end
    
end
