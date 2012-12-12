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
        xhtml.table :border => "1", :width => "100%;", :style => "width: 100%;" do
          xhtml.tr do
            xhtml.td :rowspan => 2, :valign => "top", :align => "left" do
              xhtml.img :src => item.thumbnail.url
            end
            xhtml.td :valign => "top" do
              xhtml.a  :href => item.other[:magnetlink] do
                xhtml.p "Magnet-Link"
              end
            end
            xhtml.td :valign => "top" do
              xhtml.p item.other[:size] unless item.other[:size].empty?
            end
            xhtml.td :valign => "top" do
              xhtml.p item.category 
            end
            xhtml.td :valign => "top" do
              xhtml.p item.other[:format] unless item.other[:format].empty?
            end
            xhtml.td :valign => "top" do
              xhtml.p item.other[:stats] unless item.other[:stats].empty?
            end
          end

          xhtml.tr do
            xhtml.td :colspan => 5, :valign => "top"  do
              xhtml.p "..."
            end
          end
          
          xhtml.tr do
            xhtml.td :colspan => 6 do
              xhtml.p item.other[:description], :style => "text-align:justify"
            end
          end
          
          item.other[:comments].each do |comment|
            xhtml.tr do
              xhtml.td :colspan => 6 do
                xhtml.blockquote comment
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
