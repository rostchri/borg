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
  
  
  def sfile_content_old(sfile,removeimage=true)
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
  
  def sfile_content(sfile,removeimage=true)
    capture_haml do
      unless sfile.other[:messages].nil? || sfile.other[:messages].empty?
        haml_tag :table do
          sfile.other[:messages].each_with_index do |message,index|
            haml_tag :tr do
              haml_tag :th, "#{index + 1}. Eintrag von #{sfile.other[:messages].size}"
            end
            haml_tag :tr do 
              haml_tag :td do
                content = Nokogiri::HTML(Base64::decode64(message).to_ascii)
                # remove image
                content.xpath("//img").each { |image| image.remove if image.attributes['src'].value == sfile.imageurl } unless !removeimage || sfile.imageurl.nil?
                # make spoiler visible
                content.xpath("//div[@class='body-spoiler']").each do |spoiler| 
                  spoiler.set_attribute('style','')
                end
                
                # replace text-links with real-links via link-decrypter
                content.xpath("//text()").each do |element|
                  links=[]
                  element.content = element.content.strip.gsub /(http:\/\/.*)/ do |line|
                    links << $1
                    ""
                  end
                  links.each do |l|
                    element.add_next_sibling Nokogiri::HTML("<a href='#{entrant_path(sfile) + "/#{Base64::urlsafe_encode64(l)}/decrypt/"}' target='_blank'>#{l}</a>").search('a')
                  end
                end
                
                # use linkdecryter for certain links
                content.xpath("//a[@target='_blank']").each do |link| 
                  ENV['LINKDECRYPTER_URLS'].split.map{|r| %r #{r} i }.each do |r|
                    if link.attributes['href'].value =~ r
                      link.attributes['href'].value = entrant_path(sfile) + "/#{Base64::urlsafe_encode64(link.attributes['href'].value)}/decrypt/"
                    end
                  end
                end
                haml_concat content.to_s #.to_ascii
              end
            end
          end
        end
      else
        haml_concat raw(sfile_content_old(sfile,removeimage))
      end
    end
  end

end