xml.instruct! :xml, :version => "1.0" 
xml.rss :version => "2.0", "xmlns:atom"    => "http://www.w3.org/2005/Atom", 
                           "xmlns:dc"      => "http://purl.org/dc/elements/1.1/", 
                           "xmlns:content" => "http://purl.org/rss/1.0/modules/content/", 
                           "xmlns:torrent" => "http://xmlns.ezrss.it/0.1/" do
  xml.channel do
    xml.title @title
    xml.description @description
    xml.language 'de'
    # xml.image do 
    #   xml.url "http://borg.brainabuse.de/assets/borg.gif"
    # end
    xml.ttl "60"
    
    if params[:type] == "SFile"
      xml.link sfilefeed_url(:rss)
      xml.tag! 'atom:link', :rel => 'self', :type => 'application/rss+xml', :href => sfilefeed_url(:rss)
    elsif params[:type] == "Torrent"
      xml.link torrentfeed_url(:rss) 
      xml.tag! 'atom:link', :rel => 'self', :type => 'application/rss+xml', :href => torrentfeed_url(:rss)
    end
    
    
    @feed_items.each do |item|
      xml.item do
        xml.category item.category
        xml.link entrant_url(item)
        description = []
        case item
          when Torrent
            xml.title item.title
            # torrent-magnetURI-links will not work in atom-feeds, which is the default for google-reader starred feed, 
            # so we need some other tag which will be in atom-feed later for the magnet-link
            #xml.tag!('dc:creator',item.other[:details][:'Eingetragen von:']) unless item.other[:details].nil? || item.other[:details][:'Eingetragen von:'].nil?
            xml.tag!('dc:creator',"#{item.other[:magnetlink]}&dn=#{CGI.escapeHTML(item.title)}")
            
            xml.category item.other[:format] unless item.other[:format].nil? || item.other[:format].empty?
            
            xml.torrent do
              xml.magnetURI do
                xml.cdata! "#{item.other[:magnetlink]}&dn=#{CGI.escapeHTML(item.title)}"
              end
            end unless item.other[:magnetlink].nil?
            
            description << item.category
            description << item.other[:format] unless item.other[:format].nil? || item.other[:format].empty?
            description << item.other[:size] unless item.other[:size].nil?
            description << item.other[:stats] unless item.other[:stats].nil?
            description << item.other[:details][:'IMDb Rating:'] unless item.other[:details].nil? || item.other[:details][:'IMDb Rating:'].nil?
          when SFile
            unless item.other[:movietitle].nil?
              xml.title item.other[:movietitle] 
            else
              xml.title item.title
            end
            xml.tag!('dc:creator',item.author)
            description << item.category
            description << item.infos unless item.infos.nil?
          else
            xml.tag!('dc:creator',item.type)
        end
        xml.description description.join(" ")
        xml.tag!('content:encoded') do
          xml.cdata! render("entrants/feedcontent_#{item.type.downcase}", :item => item)
        end
        xml.pubDate item.updated_at.to_s(:rfc822)
        xml.guid entrant_url(item)
      end
    end
  end
end