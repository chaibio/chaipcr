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
class SamplesController < ApplicationController
  include ParamsHelper
  
  before_filter :ensure_authenticated_user
  before_filter -> { well_layout_editable_check params[:action] == "create" }, :except => [:index]
  
  def index
    @samples = Sample.joins("inner join well_layouts on well_layouts.id = samples.well_layout_id").where(["experiment_id=? and parent_type=?", params[:experiment_id], Experiment.name]).order("samples.id")
    respond_to do |format|
      format.json { render "index", :status => :ok}
    end
  end

  def create
    @sample = Sample.new(sample_params)
    @sample.well_layout_id = @well_layout.id
    ret = @sample.save
    respond_to do |format|
      format.json { render "show", :status => (ret)? :ok : :unprocessable_entity}
    end
  end
  
  def update
    ret  = @sample.update_attributes(sample_params)
    respond_to do |format|
      format.json { render "show", :status => (ret)? :ok : :unprocessable_entity}
    end
  end

  def destroy
    ret = @sample.destroy
    respond_to do |format|
      format.json { render "destroy", :status => (ret)? :ok : :unprocessable_entity}
    end
  end

  def link
    sample_well = SamplesWell.new(:sample_id=>@sample.id, :well_num=>params[:well_num])
    ret = sample_well.save
    if !ret
      sample_well.errors.full_messages.each do |message|
        @sample.errors.add(:samples_wells, message)
      end
    end
    respond_to do |format|
      format.json { render "show", :status => (ret)? :ok : :unprocessable_entity}
    end
  end
  
  def unlink
    sample_well = SamplesWell.where(:sample_id=>@sample.id, :well_num=>params[:well_num]).first
    if sample_well
      ret = sample_well.destroy
      if !ret
        sample_well.errors.full_messages.each do |message|
          @sample.errors.add(:samples_wells, message)
        end
      end
    else
      @sample.errors.add(:samples_wells, "well num #{params[:well_num]} is not associated with this sample")
    end
    respond_to do |format|
      format.json { render "show", :status => (ret)? :ok : :unprocessable_entity}
    end
  end
  
  protected
  
  def get_object
    @sample = Sample.find_by_id(params[:id])
  end
  
end
