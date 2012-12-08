module MediapathHelper
  
  def mediapath_cols
    cols = [:idPath, :strPath, :strContent, :strScraper, :strHash, :scanRecursive, :useFolderNames, :strSettings, :noUpdate, :exclude]  
  end
  
  def mediapath_cell_format
    {:cell_format => 
      { 
      }
    }
  end
  
  def mediapaths_grid(objects,paginator=nil)
    options = { :row_layout     => mediapath_cols,
                :paginator      => paginator,
                :clickable_path =>  lambda {|obj| mediapath_path(obj)},
                #:show_action    =>  lambda {|obj| iconic_show_link(mediapath_path(obj))  },
                #:edit_action     =>  lambda {|obj| iconic_edit_link(edit_mediapath_path(obj))  if permitted_to? :edit, obj },
                #:destroy_action  =>  lambda {|obj| iconic_destroy_link(mediapath_path(obj), obj.class, obj.title) if permitted_to? :destroy, obj },
                #:format_date     =>  lambda {|datetime| l datetime, :format => :short_with_time}
              }.merge(mediapath_cell_format)
    table_grid(objects, options)
  end
  
  def mediapath_grid(object)
    options = { :vertical => true, 
                :row_layout  => mediapath_cols,
                :format_date => lambda{|datetime| l datetime, :format => :short_with_time}
              }.merge(mediapath_cell_format)
    table_grid([object], options)
  end


end