require 'net/http'
require "rexml/document"

class Reading < ActiveRecord::Base
  belongs_to :device
  has_one :stop_event
 include ApplicationHelper
  
  acts_as_mappable  :lat_column_name => :latitude,
                    :lng_column_name => :longitude

              
  def speed
    read_attribute(:speed).round
  end
  
  def get_fence_name
    if(!self.event_type.include?("geofen"))
      return nil
    else
       fence_id = self.event_type.split('_')[1]
       return Geofence.exists?(fence_id) ? Geofence.find(fence_id).name : nil
    end
  end


  def shortAddress
    if(address.nil?)
      #latitude.to_s + ", " + longitude.to_s
      get_address(latitude,longitude)
    else
      begin
          doc = REXML::Document.new address
          streetNumber = doc.get_text('/geonames/address/streetNumber').to_s
          street = doc.get_text('/geonames/address/street').to_s
          city = doc.get_text('/geonames/address/placename').to_s 
          state = doc.get_text('/geonames/address/adminName1').to_s
          streetAddress = [streetNumber, street]
          streetAddress.delete("")
          shortAddress = [ streetAddress.join(' '), city, state]
          shortAddress.delete("")
          addressString = shortAddress.join(', ')
          addressString.empty? ? latitude.to_s + ", " + longitude.to_s : addressString
      rescue        
          new_address = get_address(latitude , longitude)
          if (new_address=="")
             latitude.to_s + ", " + longitude.to_s
          else
             new_address
          end    
      end
    end
  end
  
private
    def get_address(lat,lng)
        url = "http://ws.geonames.org/findNearestAddress?lat=#{lat}&lng=#{lng}"
        # get the XML data as a string
        xml_data = Net::HTTP.get_response(URI.parse(url)).body
        # extract event information
        doc = REXML::Document.new(xml_data)
        address = ""        
        doc.elements.each('geonames/address/streetNumber') do |ele|
           address = address + ele.text + ", "   if !ele.text.nil?                  
       end
        doc.elements.each('geonames/address/street') do |ele|
           address =address + ele.text+", " if  !ele.text.nil?                  
        end    
        doc.elements.each('geonames/address/placename') do |ele|
           address = address+" " + ele.text + ", " if !ele.text.nil?                  
       end
        doc.elements.each('geonames/address/adminName1') do |ele|
           address = address+" " + ele.text  if !ele.text.nil?                  
       end           
       address
    end   
end
