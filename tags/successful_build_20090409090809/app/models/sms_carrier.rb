class SmsCarrier < ActiveRecord::Base
  def self.all_carriers
    @all_carriers ||= SmsCarrier.find(:all,:order => 'name')
  end
end
