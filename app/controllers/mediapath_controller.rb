class MediapathController < ResourcesController
  has_scope :maindir,  :type => :boolean, :default => true, :only => [:index]
end

