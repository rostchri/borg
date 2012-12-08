module ApplicationHelper
  
  def iconic_show_link(url)
    railstrap_link_to('', url, 'icon-search')
  end
  
  def iconic_edit_link(url)
    railstrap_link_to('', url, 'icon-pencil')
  end
  
  def iconic_destroy_link(url, model, identifier=nil)
    railstrap_link_to('', url, 'icon-trash', :'data-confirm' => t("form.confirm", :model => model.model_name.human, :modelidentifier => identifier), :'data-method' => "delete", :rel => "nofollow")
  end
  
  def ajax_spinner_image
    capture_haml do
      haml_concat image_tag("spinner.gif", :class => "spinner")
    end
  end

  def maintabs(options={},&block)
    options[:type]         = :pills
    options[:layout]       = :vertical
    options[:menulocation] = :leftsidebar
    tabs options do
      yield
    end
  end

  def resourcedropdownmenu(name)
    capture_haml do
      #if permitted_to? :edit
        tabmenu t("commands") do
          menuitem(railstrap_image('icon-pencil') + t("edit"), :url => edit_resource_path(resource))
          menuitem(railstrap_image('icon-trash') + t("delete"), :url => resource_path(resource), :'data-confirm' => t("#{resource_class}.delete", :name => name), :'data-method' => "delete", :rel => "nofollow") #if permitted_to? :destroy
        end
      #end
    end
	end
	
	def collectiondropdownmenu
    capture_haml do
      #if permitted_to? :new
        dropdownmenu t("commands") do
          menuitem railstrap_image('icon-plus-sign') + t("#{resource_class}.new"), :url => new_resource_path
        end
      #end
    end
  end  
  
end
