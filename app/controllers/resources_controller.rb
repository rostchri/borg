class ResourcesController < InheritedResources::Base
  has_scope :page, :default => 1
end

