class Tag < ActiveRecord::Base
  belongs_to :tagable, :polymorphic => true
  belongs_to :label
end