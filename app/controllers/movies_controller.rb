class MoviesController < ResourcesController
  
  belongs_to :label ,  :optional => true
  
  has_scope :by_label, :only => [:index]
  has_scope :by_label_key, :only => [:index]
  
  
  has_scope :order_by_rating, :type => :boolean
  has_scope :order_by_title, :type => :boolean
  has_scope :order_by_id, :type => :boolean
  has_scope :stacked, :type => :boolean
  has_scope :by_genre, :type => :array, :only => :index
  has_scope :by_title, :only => :index
  has_scope :by_plot, :only => :index
  
  respond_to :js, :only => [:index]
  
  def overview
    @views = []
    @views << {:id => 1, :title => "Alle Filme sortiert nach Bewertung", :count => Movie.count,             :url => movies_path(:order_by_rating => true, :collapsible_item => 1)}
    @views << {:id => 2, :title => "Alle Filme sortiert nach Titel",     :count => Movie.count,             :url => movies_path(:order_by_title => true, :collapsible_item => 2)}
    @views << {:id => 3, :title => "Alle Filme sortiert nach Eingang",   :count => Movie.count,             :url => movies_path(:order_by_id => true, :collapsible_item => 3)}
    @views << {:id => 4, :title => "Alle Filme aus mehreren Dateien",    :count => Movie.stacked.count,     :url => movies_path(:stacked => true, :collapsible_item => 4)}
    @views << {:id => 5, :title => "Genres",                             :count => Genre.count,             :url => genres_path(:collapsible_item => 5)}
    @views << {:title => "View 1", :count => 2}
  end
  
end

