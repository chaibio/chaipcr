class Setting < ActiveRecord::Base
  @@setting = nil
  
  def self.debug
    setting.debug
  end
    
  private
  
  def self.setting
    @@setting = Setting.first if @@setting == nil
    return @@setting
  end
end