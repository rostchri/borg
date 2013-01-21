module EntrantsHelper
  
  def entrant_cols
    cols = [:info]
  end
  
  def entrant_cell_format
    {:cell_format => 
      { 
        :info      => ->(o,v,i) { render "entrants/#{o.type.downcase}", :object => o },
        :title     => ->(o,v,i) { o.other[:tip] ? railstrap_image("icon-thumbs-up", v) : v },
        :srcurl    => ->(o,v,i) { railstrap_link_to "", v, "icon-share-alt" },
        :image     => ->(o,v,i) { image_tag v.url, :class => "img-rounded" if v.exists? },
      }
    }
  end
  
  def entrants_grid(objects,paginator=nil)
    options = { :row_layout     => entrant_cols,
                :paginator      => paginator,
                #:clickable_path =>  lambda {|obj| entrant_path(obj)},
                :format_date    =>  lambda {|datetime| l datetime, :format => :short}
              }.merge(entrant_cell_format)
    table_grid(objects, options)
  end
  
  def entrant_grid(object)
    options = { :vertical => true, 
                :row_layout  => entrant_cols,
                :format_date => lambda{|datetime| l datetime, :format => :short}
              }.merge(entrant_cell_format)
    table_grid([object], options)
  end
  
  
  def sfile_content(sfile,removeimage=true)
    content = Nokogiri::HTML(sfile.content)
    content.xpath("//img").each { |image|  image.remove if image.attributes['src'].value == sfile.imageurl } unless !removeimage || sfile.imageurl.nil?
    content.xpath("//a").each { |link| link.set_attribute('href',"http://www.boerse.bz/out/?url=#{$1}") if !link.attributes['href'].nil? && link.attributes['href'].value =~ /(http:\/\/.*.gulli.bz\/.*)/ }
    content.xpath("//div[@class='body-spoiler']").each_with_index do |spoiler,index| 
      unless  sfile.other[:spoiler].nil? || 
              sfile.other[:spoiler].empty? || 
              sfile.other[:spoiler].size <= index
        webspoiler = Nokogiri::HTML(Base64::decode64(sfile.other[:spoiler][index])).at("div[@class='body-spoiler']")
        webspoiler.set_attribute('style','')
        spoiler.replace(webspoiler)
      end
    end
    content.to_html
  end

end