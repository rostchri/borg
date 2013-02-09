module MoviesHelper
  
  # c06: Autor
  # c08: Alternative Cover
  # c11: Laufzeit
  # c13: Top 250
  # c15: Director
  # c18: Studio
  # c19: Trailer
  # c20: Alternative Fanart
  # c21: Land
  
  def movie_cols
   cols = [:index, :cover, :fanart, :movie] #:c06, :c08, :c11, :c13, :c15, :c18, :c19, :c20, :c21  
   #cols = [:index, :cover, :fanart,:c00, :path, :file]  
  end
  
  def movie_cell_format
    {:cell_format => 
      { 
        :movie          => ->(o,v,i) { render :partial => "movie", :object => o },
        :genres         => ->(o,v,i) { render :partial => "genres/genres", :object => v },
        :techinfo       => ->(o,v,i) { render "techinfo", :movie => o },
        :rating         => ->(o,v,i) { render "rating", :movie => o },
        :title          => ->(o,v,i) { render "title", :movie => o  },
        :plot           => ->(o,v,i) { render "modaldetails", :movie => o},
        :index          => ->(o,v,i) { collection.offset_value + i },
        :cover          => ->(o,v,i) { render "mediafiles/cover", :animate => false, :mediafile => o.file },
        :fanart         => ->(o,v,i) { render "mediafiles/fanart", :animate => false, :mediafile => o.file },
        :path           => ->(o,v,i) { render "mediapath/mediapath", :mediapath => v },
        :file           => ->(o,v,i) { render :partial => "mediafiles/mediafile",       :object => v },
        :settings       => ->(o,v,i) { render :partial => "mediasettings/mediasetting", :object => v },
        :details        => ->(o,v,i) { render :partial => "streamdetails/streamdetail", :object => v },
      }
    }
  end
  
  def movies_grid(objects,paginator=nil)
    options = { :row_layout     => movie_cols,
                :paginator      => paginator,
                #:clickable_path =>  lambda {|obj| movie_path(obj)},
                #:show_action    =>  lambda {|obj| iconic_show_link(movie_path(obj))  },
                #:edit_action     =>  lambda {|obj| iconic_edit_link(edit_movie_path(obj))  if permitted_to? :edit, obj },
                #:destroy_action  =>  lambda {|obj| iconic_destroy_link(movie_path(obj), obj.class, obj.title) if permitted_to? :destroy, obj },
                #:format_date     =>  lambda {|datetime| l datetime, :format => :short_with_time}
              }.merge(movie_cell_format)
    table_grid(objects, options)
  end
  
  def movie_grid(object)
    options = { :vertical => true, 
                :row_layout  => movie_cols,
                :format_date => lambda{|datetime| l datetime, :format => :short_with_time}
              }.merge(movie_cell_format)
    table_grid([object], options)
  end


end