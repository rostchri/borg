atom_feed :language => 'en-US' do |feed|
  feed.title @title
  feed.updated @updated

  @news_items.each do |item|
    next if item.updated_at.blank?
    feed.entry(item,:url => entrant_url(item)) do |entry|
      entry.url entrant_url(item)
      entry.title item.title
      entry.icon image_path(item.thumbnail.url) if item.thumbnail.exists?
      entry.content render("entrants/torrent", :object => item), :type => 'html'

      # the strftime is needed to work with Google Reader.
      entry.updated(item.updated_at.strftime("%Y-%m-%dT%H:%M:%SZ")) 

      # entry.author do |author|
      #   author.name entry.author_name)
      # end
    end
  end
  
end