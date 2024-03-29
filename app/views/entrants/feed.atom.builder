atom_feed :language => 'de-de' do |feed|
  feed.title @title
  feed.subtitle @description
  feed.updated @updated
  
  feed.logo "assets/borg.gif"
  # feed.image image_tag("borg.gif")
  # feed.icon image_tag("borg.gif")

  @feed_items.each do |item|
    next if item.updated_at.blank?
    
    feed.entry(item,:url => entrant_path(item)) do |entry|
      entry.url entrant_url(item)
      entry.title item.title
      
      entry.icon "assets/borg.gif"      
      entry.logo "assets/borg.gif"      
      entry.image "assets/borg.gif"
      # entry.logo image_tag("borg.gif")
      # entry.image image_tag("borg.gif")
      # entry.icon image_tag("borg.gif")

      #entry.summary "BLABLA"
    			
      entry.content :type => 'xhtml' do |xhtml|
        xhtml.table :border => "1", :width => "100%;", :style => "width: 100%;" do
          xhtml.tr do
            xhtml.td :rowspan => 1, :valign => "top", :align => "left" do
              xhtml.img :src => item.image.url
            end
            item.other[:details].each_slice(3).map{|i| i.map{|j| {j[0].to_s =>"#{j[1]}"}}}.each_with_index do |column,columnindex| 
              xhtml.td :valign => "top"  do
                if columnindex == 0
                  xhtml.span item.category 
                  xhtml.span item.other[:format]
                  xhtml.br
                  xhtml.span "Quelle:"
                  xhtml.a  :href => item.srcurl do
                    xhtml.span item.id
                  end
                  xhtml.span item.other[:stats] unless item.other[:stats].empty?
                  xhtml.a  :href => item.other[:magnetlink] do
                    xhtml.span "Magnet-Link"
                  end
                  xhtml.div item.other[:size] unless item.other[:size].empty?
                end
                column.each do |detail|
                  detail.each do |key,value|
                    xhtml.div "#{key} #{value}"
                  end
                end
              end
            end unless item.other[:details].nil?
          end
          
          xhtml.tr do
            xhtml.td :colspan => 8 do
              xhtml.p item.other[:description], :style => "text-align:justify"
            end
          end
          
          item.other[:comments].each do |comment|
            xhtml.tr do
              xhtml.td :colspan => 8 do
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
