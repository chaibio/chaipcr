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
  before_filter -> { well_layout_editable_check }
  before_filter :get_object, :except => [:index, :create]
  
  def index
    @samples = Sample.includes(:samples_wells).joins("inner join well_layouts on well_layouts.id = samples.well_layout_id").where(["experiment_id=? and parent_type=?", params[:experiment_id], Experiment.name]).order("samples.id")
    respond_to do |format|
      format.json { render "index", :status => :ok}
    end
  end

  def create
    @sample = Sample.new(sample_params)
    @sample.well_layout_id = @experiment.well_layout.id
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
    @sample.force_destroy = (params["force"] == true || params["force"] == "true")? true : false
    ret = @sample.destroy
    respond_to do |format|
      format.json { render "destroy", :status => (ret)? :ok : :unprocessable_entity}
    end
  end

  def links
    if @sample.belongs_to_experiment?(@experiment)
      params[:wells].each do |well_num|
        link_well(well_num)
      end
      CachedStandardCurveDatum.invalidate(@experiment.well_layout.id) if @sample.errors.empty?
    else
      @sample.errors.add(:base, "sample doesn't belong to this experiment")
    end
    
    respond_to do |format|
      format.json { render "show", :status => (@sample.errors.empty?)? :ok : :unprocessable_entity}
    end
  end
  
  def unlinks
    params[:wells].each do |well_num|
      unlink_well(well_num)
    end
    CachedStandardCurveDatum.invalidate(@experiment.well_layout.id) if @sample.errors.empty?
    respond_to do |format|
      format.json { render "show", :status => (@sample.errors.empty?)? :ok : :unprocessable_entity}
    end
  end
  
  protected
  
  def link_well(well_num)
    sample_well = SamplesWell.find_or_create(@sample, @experiment.well_layout.id, well_num, params[:notes])
    ret = sample_well.save
    if !ret
      sample_well.errors.full_messages.each do |message|
        @sample.errors.add(:samples_wells, message)
      end
    end
  end
  
  def unlink_well(well_num)
    sample_well = SamplesWell.where(:sample_id=>@sample.id, :well_layout_id=>@experiment.well_layout.id, :well_num=>well_num).first
    if sample_well
      ret = sample_well.destroy
      if !ret
        sample_well.errors.full_messages.each do |message|
          @sample.errors.add(:samples_wells, message)
        end
      end
    else
      @sample.errors.add(:samples_wells, "well num #{well_num} is not associated with this sample")
    end
  end
  
  def get_object
    @sample = Sample.find_by_id(params[:id])
    if @sample == nil
      render json: {errors: "The object doesn't exist"}, status: :unprocessable_entity
      return false
    else
      return true
    end
  end
  
end
