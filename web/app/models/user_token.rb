#
# Chai PCR - Software platform for Open qPCR and Chai's Real-Time PCR instruments.
# For more information visit http://www.chaibio.com
#
# Copyright 2016 Chai Biotechnologies Inc. <info@chaibio.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
require 'digest/sha1'

class UserToken < ActiveRecord::Base
  belongs_to :user
  before_create :generate_access_token, :set_expiry_date
  
  scope :active,  -> { where('expired_at >= ?', Time.now) }
  
  def self.digest(token)
     (!token.blank?)? Digest::SHA1.hexdigest(token) : nil
  end
  
  def token
    return @token
  end
  
  def about_to_expire
    expired_at <= 4.hours.from_now
  end
  
  def reset_expiry_date!
    set_expiry_date
    save
  end
  
  private
  
  def set_expiry_date
    self.expired_at = 1.day.from_now
  end
  
  def generate_access_token
    begin
      @token = SecureRandom.urlsafe_base64
      self.access_token = self.class.digest(@token)
    end while self.class.exists?(access_token: access_token)
  end
end