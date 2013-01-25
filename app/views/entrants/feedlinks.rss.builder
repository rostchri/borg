xml.instruct! :xml, :version => "1.0" 
xml.rss :version => "2.0", "xmlns:dc" => "http://purl.org/dc/elements/1.1/", "xmlns:content" => "http://purl.org/rss/1.0/modules/content/" do
  xml.channel do
    xml.title @title
    xml.description @description
    xml.language 'de'
    xml.image do 
      xml.url "http://borg.brainabuse.de/assets/borg.gif"
    end
    xml.ttl "60"
    xml.link torrentfeed_url(:rss) if params[:type] == "Torrent"
    xml.link sfilefeed_url(:rss) if params[:type] == "SFile"
    @feed_items.each do |item|
      xml.item do
        xml.category item.category
        description = []
        case item
          when SFile
            unless item.other[:movietitle].nil?
              xml.title item.other[:movietitle] 
            else
              xml.title item.title
            end
            xml.tag!('dc:creator',item.author)
            item.links.each do |link|
              xml.link link
            end
            description << item.category
            unless item.links.nil? || item.links.empty?
              item.clustered_links.each do |hoster,links|
          		  description << "#{hoster}: #{links.count} Links"
          		end
          	end
          else
            xml.tag!('dc:creator',item.type)
        end
        xml.description description.join(" ")
        # xml.tag!('content:encoded') do
        #   xml.cdata! render("entrants/feedcontent_#{item.type.downcase}", :item => item)
        # end
        xml.pubDate item.updated_at.to_s(:rfc822)
        xml.guid entrant_url(item)
      end
    end
  end
end