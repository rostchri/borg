module ButtonHelper
  
  
  # kickstrap-icon tag or image_tag 
  def railstrap_image(image,text=nil)
    capture_haml do
      unless image.nil?
        if image =~ /icon-/
          haml_tag :i, {:class => image}.merge(text.nil? ? {} : {:style => "margin: 0px"})
        else
          haml_concat image_tag(image, :style => "margin-bottom: -4px")
        end
      end
      haml_concat text unless text.nil?
    end
  end
  
  # kickstrap-button tags
  def kickstrap_button(text,href=nil,image=nil,button=nil,type=nil,onclick=nil,options={})
    capture_haml do
      options = {:class => "btn #{button}"}.merge({:href => href.nil? ? "#" : href}).merge(options)
      options.merge!(:type => type) unless type.nil?       
      if type == :reset 
        if href.nil? || href == "#"
          options.merge!(:href => session[:return_to])  
          options.merge!(:onclick => "window.location = '#{session[:return_to]}';")
        else
          options.merge!(:onclick => "window.location = '#{href}';")
        end
      end
      options.merge!(:onclick => onclick) unless onclick.nil?
      if options[:remote]
        options.delete(:remote)
        options.merge!(:"data-remote" => "true")
      end 
      haml_tag (type.nil? ? :a : :button) , options  do
        haml_concat railstrap_image image unless image.nil?
        haml_concat text 
      end
    end
  end
  
  # normal link_to function but with image/icon
  def kickstrap_link_to(text,href,image=nil,options={})
    capture_haml do
      unless image.nil?
        haml_concat link_to railstrap_image(image, text), href, options
      else
        haml_concat link_to text, href, options
      end
    end
  end 
  
end