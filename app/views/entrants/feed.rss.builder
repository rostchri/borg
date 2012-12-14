xml.instruct! :xml, :version => "1.0" 
xml.rss :version => "2.0" do
  xml.channel do
    xml.title @title
    xml.description @description
    xml.language 'de'
    xml.image do 
      xml.url "http://borg.brainabuse.de/assets/borg.gif"
    end
    xml.link feed_url(:rss)
        
    @feed_items.each do |item|
      xml.item do
        xml.title item.title
        xml.description do
          xml.cdata! render("entrants/feeditem", :feeditem => item)
        end
        xml.pubDate item.created_at.to_s(:rfc822)
        xml.link entrant_url(item)
        xml.guid entrant_url(item)
      end
    end
    
  end
end


