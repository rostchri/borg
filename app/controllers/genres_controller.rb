class GenresController < ResourcesController
  respond_to :js, :only => [:index]
end

