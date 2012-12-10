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
  
  
  
  
end

