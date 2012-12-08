module ApplicationHelper
  
  def ajax_spinner_image
    capture_haml do
      haml_concat image_tag("spinner.gif", :class => "spinner")
    end
  end
  
end
