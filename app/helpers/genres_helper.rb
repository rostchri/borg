module GenresHelper
  
  def genre_cols
    cols = [:name,:movies]  
  end
  
  def genre_cell_format
    {:cell_format => 
      { 
        :movies => ->(o,v,i) { link_to v.count, movies_path(:by_genre=>[o]) },
      }
    }
  end
  
  def genres_grid(objects,paginator=nil)
    options = { :row_layout     => genre_cols,
                :paginator      => paginator,
                :clickable_path =>  lambda {|obj| genre_path(obj)},
                #:show_action    =>  lambda {|obj| iconic_show_link(mediafile_path(obj))  },
                #:edit_action     =>  lambda {|obj| iconic_edit_link(edit_mediafile_path(obj))  if permitted_to? :edit, obj },
                #:destroy_action  =>  lambda {|obj| iconic_destroy_link(mediafile_path(obj), obj.class, obj.title) if permitted_to? :destroy, obj },
                #:format_date     =>  lambda {|datetime| l datetime, :format => :short_with_time}
              }.merge(genre_cell_format)
    table_grid(objects, options)
  end
  
  def genre_grid(object)
    options = { :vertical => true, 
                :row_layout  => genre_cols,
                :format_date => lambda{|datetime| l datetime, :format => :short_with_time}
              }.merge(genre_cell_format)
    table_grid([object], options)
  end


end