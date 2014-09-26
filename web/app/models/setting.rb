class Setting < ActiveRecord::Base
  @@setting = nil
    
  def self.instance
    @@setting = Setting.first if @@setting == nil
    return @@setting
  end
  
  def self.debug
    instance.debug
  end
  
  def time_zone_offset
    (time_zone.nil?)? nil : ActiveSupport::TimeZone.new(time_zone).utc_offset
  end
  
end