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
class TargetsController < ApplicationController
  include ParamsHelper
  
  before_filter :ensure_authenticated_user
  before_filter -> { well_layout_editable_check params[:action] == "create" }, :except => [:index]
  
  def index
    @targets = Target.joins("inner join well_layouts on well_layouts.id = targets.well_layout_id").where(["experiment_id=? and parent_type=?", params[:experiment_id], Experiment.name]).order("targets.id")
    respond_to do |format|
      format.json { render "index", :status => :ok}
    end
  end

  def create
    @target = Target.new(target_params)
    @target.well_layout_id = @well_layout.id
    ret = @target.save
    respond_to do |format|
      format.json { render "show", :status => (ret)? :ok : :unprocessable_entity}
    end
  end
  
  def update
    ret  = @target.update_attributes(target_params)
    respond_to do |format|
      format.json { render "show", :status => (ret)? :ok : :unprocessable_entity}
    end
  end

  def destroy
    ret = @target.destroy
    respond_to do |format|
      format.json { render "destroy", :status => (ret)? :ok : :unprocessable_entity}
    end
  end

  def links
    params[:wells].each do |well|
      link_well(well[:well_num], well[:well_type], well[:concentration])
    end
    respond_to do |format|
      format.json { render "show", :status => (@target.errors.empty?)? :ok : :unprocessable_entity}
    end
  end
  
  def unlinks
    params[:wells].each do |well_num|
      unlink_well(well_num)
    end
    respond_to do |format|
      format.json { render "show", :status => (@target.errors.empty?)? :ok : :unprocessable_entity}
    end
  end
  
  protected
  
  def link_well(well_num, well_type, concentration)
    target_well = TargetsWell.where(:target_id=>@target.id, :well_num=>well_num).first
    target_well = TargetsWell.new(:target_id=>@target.id, :well_num=>well_num) if target_well.nil?
    target_well.update_attributes(:well_type=>well_type, :concentration=>concentration)
    target_well.target = @target
    ret = target_well.save
    if !ret
      target_well.errors.full_messages.each do |message|
        @target.errors.add(:targets_wells, message)
      end
    end
  end
  
  def unlink_well(well_num)
    target_well = TargetsWell.where(:target_id=>@target.id, :well_num=>well_num).first
    if target_well
      ret = target_well.destroy
      if !ret
        target_well.errors.full_messages.each do |message|
          @target.errors.add(:targets_wells, message)
        end
      end
    else
      @target.errors.add(:targets_wells, "well num #{well_num} is not associated with this target")
    end
  end
  
  def get_object
    @target = Target.find_by_id(params[:id])
  end
  
end
