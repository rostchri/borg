module EntrantsHelper
  
  def entrant_cols
    cols = [:thumbnail,:title,:typeinfo]
  end
  
  def entrant_cell_format
    {:cell_format => 
      { 
        :typeinfo  => ->(o,v,i) { render "entrants/#{o.type.downcase}", :object => o },
        :title     => ->(o,v,i) { o.other[:tip] ? railstrap_image("icon-thumbs-up", v) : v },
        :srcurl    => ->(o,v,i) { railstrap_link_to "", v, "icon-share-alt" },
        :thumbnail => ->(o,v,i) { image_tag v.url, :class => "img-rounded" if v.exists? },
      }
    }
  end
  
  def entrants_grid(objects,paginator=nil)
    options = { :row_layout     => entrant_cols,
                :paginator      => paginator,
                :clickable_path =>  lambda {|obj| entrant_path(obj)},
                :format_date    =>  lambda {|datetime| l datetime, :format => :short}
              }.merge(entrant_cell_format)
    table_grid(objects, options)
  end
  
  def entrant_grid(object)
    options = { :vertical => true, 
                :row_layout  => entrant_cols,
                :format_date => lambda{|datetime| l datetime, :format => :short}
              }.merge(entrant_cell_format)
    table_grid([object], options)
  end

end