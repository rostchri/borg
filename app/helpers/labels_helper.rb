# -*- encoding : utf-8 -*-
module LabelsHelper
  
  def label_cols
    cols = [:id,:key,:name,:description,:created_at,:updated_at,:movies]
  end
  
  def labels_col_visible
    {:col_visible => ->(col)  {true}}
  end

  def label_col_visible
    {:col_visible => ->(col)  {true}}
  end
  
  def labels_cell_format
    {:cell_format => {
      :name       => ->(o,v,i) {link_to o.name, resource_path(o)},
      :movies     => ->(o,v,i) {link_to "#{o.movies.count}", label_movies_path(o)},
      :created_by => ->(o,v,i) {v.login},
      :updated_by => ->(o,v,i) {v.login}
    }}
  end
  
  def labels_grid(objects,paginator = nil)
    options = { #:caption => t("#{resource_class}.index"),
                :row_layout     => label_cols,
                :paginator      => paginator,
                :format_date    => ->(date) {l date, :format => :short_with_time},
                #:display_actions => role?(:masteradmin,:admin),
                #:edit_action    => ->(obj)  {link_to railstrap_image('icon-pencil'), edit_resource_path(obj) if permitted_to? :edit},
                #:destroy_action => ->(obj)  {button_to('',resource_path(obj), :method => :delete, :class=>:delete, :confirm => t("#{resource_class}.delete", :name => obj.name)) if permitted_to? :destroy},
                #:show_action    => ->(obj)  {link_to railstrap_image('icon-search'), resource_path(obj) if permitted_to? :show},
                #:clickable_path => ->(obj)  {resource_path(obj) if permitted_to? :show},
              }.merge(labels_cell_format).merge(labels_col_visible)
    
    table_grid(objects, options)
    
  end

  def label_grid(object)
    options = {:vertical       => true, 
               #:caption       => t("#{resource_class}.show", :name => object.name) ,
               :row_layout     => label_cols,
               :format_date    => ->(date) {l date, :format => :short_with_time},
              }.merge(label_col_visible).merge(labels_cell_format)
    
    table_grid([object],options)
  end

end
