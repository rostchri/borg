xml.instruct! :xml, :version => "1.0" 
xml.rss :version => "2.0", "xmlns:dc" => "http://purl.org/dc/elements/1.1/", "xmlns:content" => "http://purl.org/rss/1.0/modules/content/" do
  xml.channel do
    xml.title @title
    xml.description @description
    xml.language 'de'
    xml.image do 
      xml.url "http://borg.brainabuse.de/assets/borg.gif"
    end
    xml.link feed_url(:rss)
    xml.ttl "40"
        
    @feed_items.each do |item|
      xml.item do
        xml.title item.title
        xml.dc_subject "SUBJECT"
        # torrent.date + " " + torrent.size
        xml.tag!('dc:creator',item.other[:details][:'Eingetragen von:']) unless item.other[:details].nil? || item.other[:details][:'Eingetragen von:'].nil?
        xml.category do
          xml.cdata! item.category
        end
        description = []
        description << "Beschreibung:"
        description << item.category
        description << item.other[:format] unless item.other[:format].empty?
        description << item.other[:details][:'IMDb Rating:'] unless item.other[:details].nil? || item.other[:details][:'IMDb Rating:'].nil?
        description << item.other[:stats] unless item.other[:stats].nil?
        description << item.other[:size] unless item.other[:size].nil?
        xml.description description.join("<br>")
        xml.tag!('content:encoded') do
          xml.cdata! render("entrants/feeditem", :item => item)
        end
        xml.pubDate item.created_at.to_s(:rfc822)
        xml.link entrant_url(item)
        xml.guid entrant_url(item)
      end
    end
    
  end
end


