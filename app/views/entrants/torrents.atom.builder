atom_feed :language => 'de-de' do |feed|
  feed.title @title
  feed.subtitle "Root of all Content"
  feed.updated @updated
  
  feed.logo image_tag("borg.gif")
  feed.image image_tag("borg.gif")
  feed.icon image_tag("borg.gif")
  

  @feed_items.each do |item|
    next if item.updated_at.blank?

    
    feed.entry(item,:url => item.srcurl) do |entry|
      entry.url entrant_url(item)
      entry.title item.title
      entry.logo image_tag("borg.gif")
      entry.image image_tag("borg.gif")
      entry.icon image_tag("borg.gif")

      #entry.summary "BLABLA"
    			
      entry.content :type => 'xhtml' do |xhtml|
        xhtml.table do
          xhtml.tr do
            xhtml.td do
              xhtml.p item.category
              xhtml.p item.other[:stats]
              xhtml.p item.other[:format]
              xhtml.p item.other[:size]
              xhtml.a  :href => item.other[:magnetlink] do
                xhtml.p item.other[:magnetlink]
              end
            end
            
            xhtml.td  :valign => "top" do
              xhtml.img :src => item.thumbnail.url
            end
          end
          
          xhtml.tr do
            xhtml.td :colspan => 2 do
              xhtml.blockquote item.other[:description]
            end
          end
          
          item.other[:comments].each do |comment|
            xhtml.tr do
              xhtml.td :colspan => 2 do
                xhtml.p comment
              end
            end
          end
          
        end
      end
      
      # the strftime is needed to work with Google Reader.
      entry.updated(item.updated_at.strftime("%Y-%m-%dT%H:%M:%SZ")) 

      entry.author do |author|
        author.name "aRailsDemo"
        author.email "ohndoe@example.com"
      end
    end
    
  end
  
end
