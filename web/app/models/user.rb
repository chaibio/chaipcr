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
class User < ActiveRecord::Base
  include Swagger::Blocks

  swagger_schema :User do
    property :id do
      key :type, :integer
      key :format, :int64
      key :readOnly, true
    end
    property :name do
      key :type, :string
    end
    property :email do
      key :type, :string
    end
    property :role do
      key :type, :string
    end
    property :show_banner do
      key :type, :boolean
      key :description, 'Show getting started banner'
      key :default, true
    end
  end

  has_secure_password
  has_many :user_tokens, dependent: :destroy

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: /\A(|(([A-Za-z0-9]+_+)|([A-Za-z0-9]+\-+)|([A-Za-z0-9]+\.+)|([A-Za-z0-9]+\++))*[A-Za-z0-9]+@((\w+\-+)|(\w+\.))*\w{1,63}\.[a-zA-Z]{2,6})\z/i }
  validates :password, length:{minimum:4}, on: :create, if: '!password.blank?'

  ROLE_ADMIN    = "admin"
  ROLE_USER     = "user"
  ROLE_MAINTENANCE = "maintenance"

  default_scope { where("role != ?", ROLE_MAINTENANCE) }

  before_create do |user|
    user.role = ROLE_USER if user.role.nil?
  end

  def self.empty?
    self.count == 0
  end

  def self.create_factory_user!
    self.create(:role=>ROLE_ADMIN, :name=>"Factory", :email=>"factory@factory.com", :password=>"factory", :password_confirmation=>"factory")
  end

  def self.maintenance_user
    self.unscoped.where(:role=>ROLE_MAINTENANCE).first
  end

  def admin?
    self.role == ROLE_ADMIN || self.role == ROLE_MAINTENANCE
  end

  def role=(value)
    value = (!value.blank?)? value.strip.downcase : nil
    write_attribute(:role, value)
  end

  def email=(value)
    if !value.blank?
      write_attribute(:email, value.strip.downcase)
    end
  end

  def token
    if @user_token == nil
      @user_token = UserToken.create(:user=>self)
    end
    return (@user_token != nil)? @user_token.token : nil
  end
end
