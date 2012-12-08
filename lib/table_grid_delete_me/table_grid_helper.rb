module TableGridHelper
  
  
  def table_grid(objects, options={})
    options = {
      :table_class        => 'table table-striped table-bordered table-condensed',     # CSS class name of the table
      :table_id           => "table_#{objects.first.class.to_s.underscore.pluralize}", # CSS ID of the table
      :heading_class      => 'table_head',      # CSS class name of the first TR (one containing TH)
      :heading_id         => "table_head_#{objects.first.class.to_s.underscore.pluralize}", # CSS class for all TH elements
      :th_class           => 'table_th',        # CSS class for all TH elements
      :tr_class           => 'table_tr',        # CSS class for all TR elements
      :td_class           => 'table_td',        # CSS class for all TD elements
      :even_odd           => false,              # Should even/odd classes be added
      :format_date        => nil,               # Time formatter (receives date object, expects string). Example: lambda{|datetime| l datetime, :format => :short} 
      :numeric_td_class   => 'numeric',         # CSS class for any TDs containing a number
      :date_td_class      => 'date',            # CSS class for any TDs containing something date-like
      :string_td_class    => 'string',          # CSS class for any TDs containing a string
      :vertical           => false,             # Orientation
      :caption            => nil,               # Caption
      :clickable_path     => nil,               # vertical=false -> lambda{|object|} vertical=true -> lambda{|col|}  row will be clickable via jquery javascript-function and given url 
      :paginator          => nil,               # Paginator
      :paginator_pos      => :both,             # Position of Paginator (:botton, :top, :both)
      :objects_class      => objects.first.class, # Class of objects for i18n-localisation
      :i18n               => true,              # i18n-localisation
      :cell_format        => nil,               # Cell-Formater for specific columns. Example: {:col => lambda{|obj,value| link_to value, my_path(obj)}}
      :col_visible        => nil,               # Visiblity of columns. Example: 
      :col_invisible      => nil,               # Invisiblity of columns. Example: 
      :display_actions    => true,              # Show action-links or not
      :actions            => :left,             # Where to show the action-links :left|:right
      # Any of this will create an 'Actions' heading, the lambdas receive the object, and expect a string
      :show_action        => nil,               # lambda{|object| link_to '', my_path(object)}
      :edit_action        => nil,               # lambda{|object|} 
      :destroy_action     => nil,               # lambda{|object|}
    }.merge(options)

    options[:id] = "table-#{rand.to_s.split('.').last}" if !options[:id]

    return if objects.empty?

    if (options[:objects_class])
      options[:table_id] = "table_#{options[:objects_class].to_s.underscore.pluralize}"
      options[:heading_id] = "table_head_#{options[:objects_class].to_s.underscore.pluralize}"
    end

    # if row_layout are provided use the names in the row_layout, otherwise find all the to_s attributes and select the keys
    columns = options[:row_layout] ? options[:row_layout] : 
      objects.first.attributes.select{|k,v| v.respond_to?(:to_s)}.collect{|a| a[0]}

    show_action_links = options[:display_actions] && (options[:show_action] || options[:edit_action] || options[:destroy_action])

    capture_haml do  
      haml_tag :div, {:id => options[:id]} do
        if [:both,:top].include?(options[:paginator_pos])
          haml_tag :div, {:id => "paginator_top", :style=>"float: right;"} do
            haml_concat options[:paginator] unless options[:paginator].nil? || objects.num_pages == 1
          end
          haml_tag :div, :class => "clearboth"
        end
        haml_tag :table, {:id => options[:table_id], :class => options[:table_class]} do

          haml_tag :caption do
            haml_concat options[:caption]
          end unless options[:caption].nil?

          unless options[:vertical] # index-mode
            # Column headings
            haml_tag :thead do

              haml_tag :tr, { :id => options[:heading_id], :class => [options[:heading_class], options[:tr_class]].join(' ') } do
                haml_tag :th, { :class => options[:td_class]} do
                   haml_concat t("actions") 
                end if show_action_links && options[:actions] == :left
                # TODO: sort-order-links
                columns.each do |col|
                  if (options[:col_visible].nil?   ||  options[:col_visible].call(col.to_sym)) &&
                     (options[:col_invisible].nil? || !options[:col_invisible].call(col.to_sym))   
                    unless options[:objects_class] && options[:i18n]
                      haml_tag :th, { :class => options[:td_class]} do 
                        haml_concat col.to_s.capitalize.humanize 
                      end
                    else
                      haml_tag :th, { :class => options[:td_class]} do 
                        haml_concat options[:objects_class].human_attribute_name(col) 
                      end
                    end
                  end
                end

                haml_tag :th, { :class => options[:td_class]} do
                   haml_concat t("actions") 
                end  if show_action_links && options[:actions] == :right
              end
            end

            # tbody
            haml_tag :tbody, :id => "tbody_#{options[:table_id]}" do

              objects.each_with_index do |obj,idx|
                tr_classes = [ options[:tr_class] ]
                tr_classes << ((idx + 1).odd? ? 'odd' : 'even') if options[:even_odd]
                haml_tag :tr, {:id => "#{obj.class.to_s.underscore}_#{obj.id}", :class => tr_classes.join(' ')}.merge(options[:clickable_path].nil? ? {}:{:rel=> options[:clickable_path].call(obj)}) do

                  if show_action_links && options[:actions] == :left
                    haml_tag :td, { :class => "#{options[:td_class]} actions" } do
                      [:show_action, :edit_action, :destroy_action].each do |obj_action|        
                        haml_concat options[obj_action].call(obj) if options[obj_action]
                      end
                    end
                  end

                  columns.each do |col|
                    if (options[:col_visible].nil?   ||  options[:col_visible].call(col.to_sym)) &&
                       (options[:col_invisible].nil? || !options[:col_invisible].call(col.to_sym))   

                      td_classes  = [options[:td_class], col]
                      td_classes  << "clickable" unless options[:clickable_path].nil? || options[:clickable_path].call(obj).nil?
                      td_value    = obj.respond_to?(col) ? obj.send(col) : nil

                      case td_value.class.to_s
                      when "String"
                        td_classes << options[:string_td_class]
                      when "Numeric"
                        td_classes << options[:numeric_td_class]
                      when "Time", "Date", "DateTime","ActiveSupport::TimeWithZone"
                        td_value = options[:format_date].call(td_value) if options[:format_date]
                        td_classes << options[:date_td_class]
                      end
                      haml_tag :td, {:class => td_classes.join(' ')} do
                        if options[:cell_format] && options[:cell_format][col]
                          if obj.respond_to?(col)
                           haml_concat options[:cell_format][col].call(obj,obj.send(col),idx+1)
                          else
                           haml_concat options[:cell_format][col].call(obj,td_value,idx+1)
                          end
                        else
                          haml_concat td_value
                        end
                      end

                    end
                  end

                  if show_action_links && options[:actions] == :right
                    haml_tag :td, { :class => "#{options[:td_class]} actions" } do
                      [:show_action, :edit_action, :destroy_action].each do |obj_action|        
                        haml_concat options[obj_action].call(obj) if options[obj_action]
                      end
                    end
                  end

                end # end haml_tag :tr                   
              end #end objects.each_with_index
            end # end haml_tag :tbody


          else # view-mode
            objects.each do |obj|
              columns.each_with_index do |col,idx|
                if (options[:col_visible].nil?   ||  options[:col_visible].call(col.to_sym)) &&
                   (options[:col_invisible].nil? || !options[:col_invisible].call(col.to_sym))   
                  tr_classes = [ options[:tr_class] ]

                  # Value
                  if options[:cell_format] && options[:cell_format][col]
                    if obj.respond_to?(col)
                      td_value = options[:cell_format][col].call(obj,obj.send(col),idx+1)
                    else
                      td_value = options[:cell_format][col].call(obj,nil,idx+1)
                    end
                  else
                    td_value = obj.send(col)
                  end

                  haml_tag :tr, {:class => tr_classes.join(' ') }.merge(options[:clickable_path].nil? ? {} : {:rel=> options[:clickable_path].call(col,td_value)}) do
                    # Column headings  
                    heading_classes = [options[:heading_class], options[:th_class]]
                    heading_classes << "clickable" unless options[:clickable_path].nil? || options[:clickable_path].call(col,td_value).nil? || options[:clickable_path].call(col,td_value).empty?
                    unless options[:objects_class] && options[:i18n]
                      haml_tag :th, { :class => heading_classes.join(' ')} do
                        haml_concat col.to_s.capitalize.humanize 
                      end
                    else
                      haml_tag :th, { :class => heading_classes.join(' ')} do
                        haml_concat options[:objects_class].human_attribute_name(col) 
                      end
                    end
                    td_classes  = [options[:td_class], col]
                    td_classes << "clickable" unless options[:clickable_path].nil? || options[:clickable_path].call(col,td_value).nil? || options[:clickable_path].call(col,td_value).empty?
                    td_classes  << ((idx + 1).odd? ? 'odd' : 'even') if options[:even_odd]
                    case td_value.class.to_s
                    when "String"
                      td_classes << options[:string_td_class]
                    when "Numeric"
                      td_classes << options[:numeric_td_class]
                    when "Time", "Date", "DateTime","ActiveSupport::TimeWithZone"
                      td_value = options[:format_date].call(td_value) if options[:format_date]
                      td_classes << options[:date_td_class]
                    end
                    haml_tag :td, { :class => td_classes.join(' '), :id => "#{obj.class.to_s.underscore}_#{obj.id}"} do
                      haml_concat td_value
                    end
                  end
                end
              end
            end
          end
        end #end haml_tag :table
        if [:both,:bottom].include?(options[:paginator_pos])
          haml_tag "div", {:id => "paginator_bottom", :style=>"float: right;"} do
            haml_concat options[:paginator] unless options[:paginator].nil? || objects.num_pages == 1
          end
        end

        unless options[:clickable_path].nil?
          haml_tag(:script) do
            javascript = <<-EOF
//<![CDATA[
(function($){
  $('th.clickable').click(function(){window.location = $(this).closest('tr').attr('rel');})
  $('td.clickable').click(function(){window.location = $(this).closest('tr').attr('rel');})
})(jQuery);
//]]>
EOF
            haml_concat(javascript)
          end
        end
      end
    end #end capture_haml
  end #end def display_grid


end