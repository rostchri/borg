xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0", "xmlns:dc" => "http://purl.org/dc/elements/1.1/", "xmlns:content" => "http://purl.org/rss/1.0/modules/content/", "xmlns:atom" => "http://www.w3.org/2005/Atom" do
  xml.channel do
    xml.title @title
    xml.description @description
    xml.language 'de'
    # xml.image do 
    #   xml.url "http://borg.brainabuse.de/assets/borg.gif"
    # end
    xml.ttl "60"
    
    if params[:type] == "SFile"
      xml.tag! 'atom:link', :rel => 'self', :type => 'application/rss+xml', :href => sfilefeedlinks_url(:rss)
      xml.link sfilefeedlinks_url(:rss)
    end
    
    @feed_items.each do |item|
      xml.item do
        xml.category item.category
        description = []
        case item
          when SFile
            xml.title item.title
            xml.tag!('dc:creator',item.author)
            xml.link entrant_url(item)
            # item.links.each do |link|
            #   xml.link link
            # end
            #description << item.category
            unless item.links.nil? || item.links.empty?
              # item.clustered_links.each do |hoster,links|
              #   description << "#{hoster}: #{links.count} Links\n"
              # end
              item.links.each do |link|
                description << link
              end
            end
          else
            xml.tag!('dc:creator',item.type)
        end
        xml.description description.join(" ")
        # xml.tag!('content:encoded') do
        #   xml.cdata! render("entrants/feedlinks_#{item.type.downcase}", :item => item)
        # end
        xml.pubDate item.updated_at.to_s(:rfc822)
        xml.guid entrant_url(item)
      end
    end
  end
end