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
class SettingsController < ApplicationController
  include ParamsHelper
  include Swagger::Blocks
  respond_to :json

  resource_description {
    formats ['json']
  }

  def_param_group :settings do
    param :settings, Hash, :desc => "Global Settings", :required => true do
      param :time_zone, String, :desc=> "{ 'International Date Line West' => 'Pacific/Midway', 'Midway Island' => 'Pacific/Midway', 'American Samoa' => 'Pacific/Pago_Pago', 'Hawaii' => 'Pacific/Honolulu', 'Alaska' => 'America/Juneau', 'Pacific Time (US & Canada)' => 'America/Los_Angeles', 'Tijuana' => 'America/Tijuana', 'Mountain Time (US & Canada)' => 'America/Denver', 'Arizona' => 'America/Phoenix', 'Chihuahua' => 'America/Chihuahua', 'Mazatlan' => 'America/Mazatlan', 'Central Time (US & Canada)' => 'America/Chicago', 'Saskatchewan' => 'America/Regina', 'Guadalajara' => 'America/Mexico_City', 'Mexico City' => 'America/Mexico_City', 'Monterrey' => 'America/Monterrey', 'Central America' => 'America/Guatemala', 'Eastern Time (US & Canada)' => 'America/New_York', 'Indiana (East)' => 'America/Indiana/Indianapolis', 'Bogota' => 'America/Bogota', 'Lima' => 'America/Lima', 'Quito' => 'America/Lima', 'Atlantic Time (Canada)' => 'America/Halifax', 'Caracas' => 'America/Caracas', 'La Paz' => 'America/La_Paz', 'Santiago' => 'America/Santiago', 'Newfoundland' => 'America/St_Johns', 'Brasilia' => 'America/Sao_Paulo', 'Buenos Aires' => 'America/Argentina/Buenos_Aires', 'Montevideo' => 'America/Montevideo', 'Georgetown' => 'America/Guyana', 'Greenland' => 'America/Godthab', 'Mid-Atlantic' => 'Atlantic/South_Georgia', 'Azores' => 'Atlantic/Azores', 'Cape Verde Is.' => 'Atlantic/Cape_Verde', 'Dublin' => 'Europe/Dublin', 'Edinburgh' => 'Europe/London', 'Lisbon' => 'Europe/Lisbon', 'London' => 'Europe/London', 'Casablanca' => 'Africa/Casablanca', 'Monrovia' => 'Africa/Monrovia', 'UTC' => 'Etc/UTC', 'Belgrade' => 'Europe/Belgrade', 'Bratislava' => 'Europe/Bratislava', 'Budapest' => 'Europe/Budapest', 'Ljubljana' => 'Europe/Ljubljana', 'Prague' => 'Europe/Prague', 'Sarajevo' => 'Europe/Sarajevo', 'Skopje' => 'Europe/Skopje', 'Warsaw' => 'Europe/Warsaw', 'Zagreb' => 'Europe/Zagreb', 'Brussels' => 'Europe/Brussels', 'Copenhagen' => 'Europe/Copenhagen', 'Madrid' => 'Europe/Madrid', 'Paris' => 'Europe/Paris', 'Amsterdam' => 'Europe/Amsterdam', 'Berlin' => 'Europe/Berlin', 'Bern' => 'Europe/Berlin', 'Rome' => 'Europe/Rome', 'Stockholm' => 'Europe/Stockholm', 'Vienna' => 'Europe/Vienna', 'West Central Africa' => 'Africa/Algiers', 'Bucharest' => 'Europe/Bucharest', 'Cairo' => 'Africa/Cairo', 'Helsinki' => 'Europe/Helsinki', 'Kyiv' => 'Europe/Kiev', 'Riga' => 'Europe/Riga', 'Sofia' => 'Europe/Sofia', 'Tallinn' => 'Europe/Tallinn', 'Vilnius' => 'Europe/Vilnius', 'Athens' => 'Europe/Athens', 'Istanbul' => 'Europe/Istanbul', 'Minsk' => 'Europe/Minsk', 'Jerusalem' => 'Asia/Jerusalem', 'Harare' => 'Africa/Harare', 'Pretoria' => 'Africa/Johannesburg', 'Moscow' => 'Europe/Moscow', 'St. Petersburg' => 'Europe/Moscow', 'Volgograd' => 'Europe/Moscow', 'Kuwait' => 'Asia/Kuwait', 'Riyadh' => 'Asia/Riyadh', 'Nairobi' => 'Africa/Nairobi', 'Baghdad' => 'Asia/Baghdad', 'Tehran' => 'Asia/Tehran', 'Abu Dhabi' => 'Asia/Muscat', 'Muscat' => 'Asia/Muscat', 'Baku' => 'Asia/Baku', 'Tbilisi' => 'Asia/Tbilisi', 'Yerevan' => 'Asia/Yerevan', 'Kabul' => 'Asia/Kabul', 'Ekaterinburg' => 'Asia/Yekaterinburg', 'Islamabad' => 'Asia/Karachi', 'Karachi' => 'Asia/Karachi', 'Tashkent' => 'Asia/Tashkent', 'Chennai' => 'Asia/Kolkata', 'Kolkata' => 'Asia/Kolkata', 'Mumbai' => 'Asia/Kolkata', 'New Delhi' => 'Asia/Kolkata', 'Kathmandu' => 'Asia/Kathmandu', 'Astana' => 'Asia/Dhaka', 'Dhaka' => 'Asia/Dhaka', 'Sri Jayawardenepura' => 'Asia/Colombo', 'Almaty' => 'Asia/Almaty', 'Novosibirsk' => 'Asia/Novosibirsk', 'Rangoon' => 'Asia/Rangoon', 'Bangkok' => 'Asia/Bangkok', 'Hanoi' => 'Asia/Bangkok', 'Jakarta' => 'Asia/Jakarta', 'Krasnoyarsk' => 'Asia/Krasnoyarsk', 'Beijing' => 'Asia/Shanghai', 'Chongqing' => 'Asia/Chongqing', 'Hong Kong' => 'Asia/Hong_Kong', 'Urumqi' => 'Asia/Urumqi', 'Kuala Lumpur' => 'Asia/Kuala_Lumpur', 'Singapore' => 'Asia/Singapore', 'Taipei' => 'Asia/Taipei', 'Perth' => 'Australia/Perth', 'Irkutsk' => 'Asia/Irkutsk', 'Ulaanbaatar' => 'Asia/Ulaanbaatar', 'Seoul' => 'Asia/Seoul', 'Osaka' => 'Asia/Tokyo', 'Sapporo' => 'Asia/Tokyo', 'Tokyo' => 'Asia/Tokyo', 'Yakutsk' => 'Asia/Yakutsk', 'Darwin' => 'Australia/Darwin', 'Adelaide' => 'Australia/Adelaide', 'Canberra' => 'Australia/Melbourne', 'Melbourne' => 'Australia/Melbourne', 'Sydney' => 'Australia/Sydney', 'Brisbane' => 'Australia/Brisbane', 'Hobart' => 'Australia/Hobart', 'Vladivostok' => 'Asia/Vladivostok', 'Guam' => 'Pacific/Guam', 'Port Moresby' => 'Pacific/Port_Moresby', 'Magadan' => 'Asia/Magadan', 'Solomon Is.' => 'Pacific/Guadalcanal', 'New Caledonia' => 'Pacific/Noumea', 'Fiji' => 'Pacific/Fiji', 'Kamchatka' => 'Asia/Kamchatka', 'Marshall Is.' => 'Pacific/Majuro', 'Auckland' => 'Pacific/Auckland', 'Wellington' => 'Pacific/Auckland', 'Nuku'alofa' => 'Pacific/Tongatapu', 'Tokelau Is.' => 'Pacific/Fakaofo', 'Chatham Is.' => 'Pacific/Chatham', 'Samoa' => 'Pacific/Apia' }", :required => true
      param :debug, :bool, :desc => "machine is in debug mode", :required => false
    end
  end

  swagger_path '/settings' do
    operation :get do
      key :summary, 'Device settings'
      key :description, 'Returns device specific time zone information'
      key :produces, [
        'application/json',
      ]
      response 200 do
        key :description, 'settings response'
        schema do
          key :type, :object
          key :'$ref', :Settings
        end
      end
    end
  end

  api :GET, "/settings", "Show Settings"
  example "{'settings':{'time_zone':'Pacific Time (US & Canada)','debug':false,'time_zone_offset':-28800}"
  description "time_zone_offset is in seconds"
  def show
    @settings = Setting.instance
    respond_to do |format|
      format.json { render "show", :status => (!@settings.nil?)? :ok : :unprocessable_entity}
    end
  end

  #to check if the put thing below is correct

  swagger_path '/settings' do
    operation :put do
      key :description, 'Update Settings'
      key :produces, [
        'application/json',
      ]
      parameter do
        key :name, :settings
        key :in, :body
        key :description, 'Settings to update'
        key :required, true
        schema do
           key :'$ref', :Settings
         end
      end
      response 200 do
        key :description, 'Settings response'
        schema do
          key :type, :object
          items do
            key :'$ref', :Settings
          end
        end
      end
    end
  end

  api :PUT, "/settings", "Update Settings"
  param_group :settings
  see "settings#show", "json response"
  def update
    @settings  = Setting.instance
    ret  = @settings.update_attributes(settings_params)
    respond_to do |format|
      format.json { render "show", :status => (ret)? :ok : :unprocessable_entity}
    end
  end
end
