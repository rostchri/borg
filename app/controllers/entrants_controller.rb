class EntrantsController < ResourcesController
  has_scope :by_date, :type => :array
  has_scope :by_category, :type => :array
  
  respond_to :js, :only => [:index]
  
  def overview
    @current_objects = Entrant.sum_and_group_by_date_and_category.inject({}) do |r,i| 
      r[i.date]={:all => 0} if r[i.date].nil?
      r[i.date][:all] += i.count.to_i
      r[i.date][i.category.to_sym] = i.count.to_i
      r
    end
  end
  
  
  def feed
    # this will be the name of the feed displayed on the feed reader
    @title = "FEED title"
    # the news items
    @news_items = Entrant.all
    # this will be our Feed's update timestamp
    @updated = @news_items.first.updated_at unless @news_items.empty?
    respond_to do |format|
      format.atom { render :layout => false }
      # we want the RSS feed to redirect permanently to the ATOM feed
      format.rss { redirect_to feed_path(:format => :atom), :status => :moved_permanently }
    end
  end
  
  
  
  
end
