module MediafilesHelper
  
  def mediafile_cols
    cols = [:idFile, :idPath, :strFilename, :playCount, :lastPlayed]  
  end
  
  def mediafile_cell_format
    {:cell_format => 
      { 
        # :informedusers   => ->(o,v,i) { ajaxitems v, 0,  :action => :mediafileusers, :partial => "users/user", :id => o.id, :onempty => t("ajaxitems.empty_mediafileusers") },
        # :mediafiletype     => ->(o,v,i) { mediafiletype(o.mediafiletype) },
        # :readerstatus    => ->(o,v,i) { mediafilemark(!o.user_is_informed?(current_user)) },
        # :information     => ->(o,v,i) { render :partial => "mediafiles/modalmediafile", :object => o },
        # :displayed_since => ->(o,v,i) { l(v, :format => :short) unless v.nil? },
        # :active_until    => ->(o,v,i) { l(v, :format => :short) unless v.nil? },
      }
    }
  end
  
  def mediafiles_grid(objects,paginator=nil)
    options = { :row_layout     => mediafile_cols,
                :paginator      => paginator,
                :clickable_path =>  lambda {|obj| mediafile_path(obj)},
                #:show_action    =>  lambda {|obj| iconic_show_link(mediafile_path(obj))  },
                #:edit_action     =>  lambda {|obj| iconic_edit_link(edit_mediafile_path(obj))  if permitted_to? :edit, obj },
                #:destroy_action  =>  lambda {|obj| iconic_destroy_link(mediafile_path(obj), obj.class, obj.title) if permitted_to? :destroy, obj },
                #:format_date     =>  lambda {|datetime| l datetime, :format => :short_with_time}
              }.merge(mediafile_cell_format)
    table_grid(objects, options)
  end
  
  def mediafile_grid(object)
    options = { :vertical => true, 
                :row_layout  => mediafile_cols,
                :format_date => lambda{|datetime| l datetime, :format => :short_with_time}
              }.merge(mediafile_cell_format)
    table_grid([object], options)
  end


end