module MenuTabsHelper
  
  def tab_depth=(value)
    @tab_depth = value
  end
  
  def tab_depth
    @tab_depth || 0
  end

  def menu_number=(value)
    @menu_number = value
  end
  
  def menu_number
    @menu_number || 0
  end
  
  def dropdownmenu(title,options={}, &block)
    # initialize structured data about menu
    @menuinfo = {} if @menuinfo.nil?

    options[:id] = "dmenu-#{rand.to_s.split('.').last}" if options[:id].nil? # generate random-id if no id is given
    options[:menuitems] = []
    options[:title] = title
    
    mymenu = self.menu_number
    myid    = options[:id]
        
    # increase menu-number
    self.menu_number += 1
    
    # save options for this menu
    @menuinfo[menu_number] = options if @menuinfo[menu_number].nil?
    
    # execute block to include sub menuitems
    yield options['id']
        
    htmlmenu = ""
    menu = @menuinfo[menu_number]
    printf "dropdownmenu: %s  %s\n", menu[:id], strip_tags(menu[:title]).squish
    htmlmenu = capture_haml do
      menuitems = capture_haml do
        classes = ["dropdown"]
        classes << "active" if menu[:active]
        haml_tag "li", {:class => classes} do
          haml_tag "a", {:href => "#", :class=>"dropdown-toggle", :'data-toggle'=>'dropdown'} do
            haml_concat menu[:title]
            haml_tag "b", {:class=>"caret"}
          end
          haml_tag "ul", {:class=>"dropdown-menu"} do
            menu[:menuitems].each_with_index do |menuitem,menuitemindex|
              printf " menuitem %s %s\n", menuitem[:id], strip_tags(menuitem[:title]).squish
              active = "active" if menuitem[:active]
              haml_tag "li", {:class => active} do
                opts = {:href => menuitem[:url].nil? ? "##{menu[:id]}" : menuitem[:url]}
                opts.merge!({:'data-toggle' => "tab"})                          if menuitem[:url].nil?
                opts.merge!({:rel => menuitem[:rel]})                       unless menuitem[:rel].nil?
                opts.merge!({:rel => "#{menuitem[:ajax]}"})                 unless menuitem[:ajax].nil?
                opts.merge!({:'data-method'  => menuitem[:'data-method']})  unless menuitem[:'data-method'].nil?
                opts.merge!({:'data-confirm' => menuitem[:'data-confirm']}) unless menuitem[:'data-confirm'].nil?
                haml_tag "a", opts do
                  haml_concat menuitem[:title]
                end
              end
            end
          end
        end
      end
      if menu[:tabmenu]
        haml_concat menuitems
      else
        # wrap menuitems inside ul-tag if not part of tabs
        haml_tag "ul", {:class => ["nav", "nav-pills"]} do
          haml_concat menuitems
        end
      end
    end
    htmlmenu
	end
	

  def tabs(options={}, &block)
    # return structured data about all tabs if no block is given
    return @tabinfo unless block_given?

    # initialize structured data about tabs
    @tabinfo = {} if @tabinfo.nil?
    
    # assemble options for this tab
    options[:id] = "tabs-#{rand.to_s.split('.').last}" if options[:id].nil? # generate random-id if no id is given
    options[:tabs] = []
    
    # type: tabs (default) pills or list
    options[:type] ||= :tabs
    options[:type] = {:tabs => "nav-tabs", :pills => "nav-pills", :list => "nav-list"}[options[:type]]
    
    # menulocation: render menu to a different location (for example: side-bar)
    # options[:menulocation] ||= :sidebar
    
    # contentlocation: render content to a different location (for example: contentframe)
    # options[contentlocation] ||=  :contentframe
    
    # layout: :vertical (instead of horizontal menu-items). only usefull for :tabs or :pills because :lists are always :vertical
    options[:layout] = {:vertical => "nav-stacked"}[options[:layout]]
    
    # tabposition: (can only be used with :tabs)
    # you can arrange tabs on different positions: left, right, bottom. default position is: top
    # don't use tabposition together with options :menulocation, :contentlocation or :layout
    # if you use :left or :right the tab-content-width may need to be customized
    options[:tabposition] = {:right => "tabs-right", :left => "tabs-left", :bottom => "tabs-below"}[options[:tabposition]]
    
    
    # increase tab-depth
    self.tab_depth += 1
        
    @tabinfo[tab_depth] = options if @tabinfo[tab_depth].nil?

    # execute block to include sub tabs
    yield options['id']
    
    # decrease tab-depth
    self.tab_depth -= 1
    
    # if in first depth return output 
    if self.tab_depth == 0 
      # creation of menus in tabs[:htmlmenu] for all tabs
      tabdepth = 0
      @tabinfo.each do |tabskey,tabs| 
        tabdepth += 1
        spaces = 1.upto(tabdepth).map{"  "}.join
        printf "%s%s type: %s layout: %s menulocation: %s contentlocation: %s tabposition: %s spinner: %s\n", spaces, tabs[:id], tabs[:type], tabs[:layout], tabs[:menulocation], tabs[:contentlocation], tabs[:tabposition], tabs[:spinner]
        tabs[:htmlmenu] = capture_haml do # saving menu-html/haml-output
          haml_tag "ul", {:class=>"nav #{tabs[:type]} #{tabs[:layout]}"}.merge(tabs[:id].nil? ? {} : {:id => tabs[:id]}) do
            tabs[:tabs].each_with_index do |tab,tabindex|
              printf " %s%s Title: %s\n", spaces,  tab[:id], strip_tags(tab[:title]).squish
              if tab[:menu].nil?
                opts = {:class => tab[:active] ? ' active' : ''}
                haml_tag "li", opts do
                  haml_tag "a", {:href => tab[:url].nil? ? "##{tab[:id]}" : tab[:url]}.merge(tab[:url].nil? ? {:'data-toggle' => "tab"} : {}).merge(tab[:ajax].nil? ? {} : {:rel =>  "#{tab[:ajax]}"}) do
                    haml_concat tab[:title]
                  end
                end
              else
                haml_concat tab[:menu]
              end
            end
          end
        end
      end

      # creation of contents in tabs[:htmlcontent] for all tabs
      tabdepth = 0
      @tabinfo.each do |tabskey,tabs| 
        tabdepth += 1
        spaces = 1.upto(tabdepth).map{"  "}.join
        tabs[:htmlcontent] = capture_haml do # saving content-html/haml-output to tabdata
          # create spinner-image
          if tabs[:spinner]
            haml_tag "div", :style => "width:150px; margin: 150px auto; display: none;", :id => "ajax_loading_spinner" do
              haml_concat image_tag("spinner.gif")
            end
            haml_concat javascript_tag <<-EOF
function disableLink(e) {
e.preventDefault();
return false;
}
$("#ajax_loading_spinner").bind("ajaxSend", function(){
$("ul##{tabs[:id]} > li > a[data-toggle='tab']").bind('click', disableLink);
$("#div-#{tabs[:id]}").hide();
$(this).show();
})
$("#ajax_loading_spinner").bind("ajaxComplete", function(){
  $(this).hide();
  $("#div-#{tabs[:id]}").show();
  $("ul##{tabs[:id]} > li > a[data-toggle='tab']").unbind('click', disableLink);
})
EOF
          end

          haml_tag "div", {:id => "div-#{tabs[:id]}", :class => 'tab-content'}.merge(["tabs-right","tabs-left"].include?(tabs[:tabposition]) ? {:style => "width: 75%;"} : {}) do
            tabs[:tabs].each_with_index do |tab,tabindex|
              opts = {:id => "#{tab[:id]}", :class=>"tab-pane#{tab[:active] ? ' active' : ''}"}
              haml_tag "div", opts do
                haml_tag "p"  do
                  haml_concat tab[:content]
                end
              end
            end 
          end 
        end
      end

      # rendering tabs[:htmlmenu] and tabs[:htmlcontent] for all tabs to 
      # other destinations if this is requested via :menulocation- or :contentlocation - options
      @tabinfo.each do |tabskey,tabs|
        content_for tabs[:menulocation], tabs[:htmlmenu]  unless tabs[:menulocation].nil?
        content_for tabs[:contentlocation], tabs[:htmlcontent] unless tabs[:contentlocation].nil?
      end

      # normal direct and sequential rendering of tabs[:htmlmenu] and tabs[:htmlcontent] for all tabs
      mainresult = capture_haml do
        tabdepth = 0
        @tabinfo.each do |tabskey,tabs|
          tabdepth += 1
          spaces = 1.upto(tabdepth).map{"  "}.join
          # building javascript-code to show/open tabs according to clicked ones
          result = capture_haml do haml_concat javascript_tag <<-EOF
$(document).ready(function() {
  $("##{tabs[:id]}").bind('shown', function (e) {
    hrefparts = $(e.target).attr('href').split("#");
    if (e.target.rel) { $.ajax({url: e.target.rel, success: function(data) { $("div.tab-pane#"+hrefparts[1]).html(data);}});}
  });
});
EOF
          end
          haml_tag "div", {:class=>"tabbable #{tabs[:tabposition]}"} do
            # normal rendering
            unless tabs[:tabposition].nil? || tabs[:tabposition] != "tabs-below"
              # reverse order if tabs-below
              result += tabs[:htmlcontent] unless tabs[:contentlocation]
              result += tabs[:htmlmenu] unless tabs[:menulocation]
            else
              result += tabs[:htmlmenu] unless tabs[:menulocation]
              result += tabs[:htmlcontent] unless tabs[:contentlocation]
            end
            haml_concat result
          end
        end
      end
      mainresult
    else
      nil
    end
  end
  
  
  # this is used in a tabs-block and creates a new tab. leads to a new menuitem and a new tab-content
  def tab(title, options={}, &block)
    options[:id]      = "tab-#{rand.to_s.split('.').last}" if options[:id].nil?
    options[:title]   = title
    options[:content] = block_given? ? capture(&block) : nil
    @tabinfo[tab_depth][:tabs] << options
    nil
  end

  # this is used in a tabs-block and creates new dropdown-menuitems without tab-content
  # the dropdown-menuitems are rendered in the menu-function and stored in @tabinfo-hash
  def tabmenu(title, options={}, &block)
    options[:id]      = "tabmenu-#{rand.to_s.split('.').last}" if options[:id].nil?
    options[:title]   = title
    options[:tabmenu] = true
    options[:menu]    = dropdownmenu(title,options,&block)
    @tabinfo[tab_depth][:tabs] << options
    nil
  end

  # this is used in a tabmenu-block and creates a dropdown-menuitem
  def menuitem(title, options={}, &block)
    options[:id] = "mitem-#{rand.to_s.split('.').last}" if options[:id].nil?
    options[:title]   = title
    @menuinfo[menu_number][:menuitems] << options
    nil
  end
  
end