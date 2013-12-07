class Run < ActiveRecord::Base
  belongs_to :protocol
  
  scope :unfinished, -> { where('run_at is NULL').order('updated_at DESC') }
end
