# -*- encoding : utf-8 -*-
require 'feedzirra'

module Scraper
  
  
  class BoerseSource
    attr_accessor :feeds
    @@stats = {}
    
    def initialize
      @@stats = {}
      # Feedzirra::Feed.add_common_feed_element('ttl')
      # Feedzirra::Feed.add_common_feed_element('generator')
      # Feedzirra::Feed.add_common_feed_entry_element('ttl')
      @feeds = Feedzirra::Feed.fetch_and_parse ENV['BOERSE_FEEDS'].split(",").map{|id| "#{ENV['BOERSE_FEED_URL']}#{id}"}, 
                                               :on_success => ->(url, feed) { BoerseSource.items(feed)}
      stats
      nil
    end
    
    def update
      @feeds.each do |u,feed|
        @@stats[feed.feed_url][:last] = {:updated => 0, :new => 0}
        updated_feed = Feedzirra::Feed.update(feed)
        unless updated_feed.is_a? Array
          BoerseSource.items updated_feed, false 
          puts "#{updated_feed.updated?} #{updated_feed.last_modified}"
        end
      end
      stats
      nil
    end
    
    def stats
      total = {:last => {:updated => 0, :new => 0}, :total => {:updated => 0, :new => 0}}
      @feeds.each do |u,feed|
        total[:last][:new]      += @@stats[feed.feed_url][:last][:new]
        total[:last][:updated]  += @@stats[feed.feed_url][:last][:updated]
        total[:total][:new]     += @@stats[feed.feed_url][:total][:new]
        total[:total][:updated] += @@stats[feed.feed_url][:total][:updated]
        printf "### Zuletzt aktualisiert: %3d neu: %3d Total aktualisiert: %3d neu: %3d ### %s\n",  @@stats[feed.feed_url][:last][:updated], 
                                                                                                    @@stats[feed.feed_url][:last][:new],
                                                                                                    @@stats[feed.feed_url][:total][:updated], 
                                                                                                    @@stats[feed.feed_url][:total][:new],
                                                                                                    feed.title
      end
      printf "### Zuletzt aktualisiert: %3d neu: %3d Total aktualisiert: %3d neu: %3d ### Total\n", total[:last][:updated], 
                                                                                          total[:last][:new],
                                                                                          total[:total][:updated], 
                                                                                          total[:total][:new]
      nil
    end
        
    def self.items(feed,only_new=false)
     begin
      @@stats[feed.feed_url] = {:total => {:updated => 0, :new => 0}} if @@stats[feed.feed_url].nil?
      @@stats[feed.feed_url][:last] = {:updated => 0, :new => 0}
      printf("### %s %s [%s]\n", feed.title, feed.last_modified.strftime("%d.%m.%y %a %H:%M"), feed.feed_url) unless (only_new ? feed.new_entries : feed.entries).empty?
      (only_new ? feed.new_entries : feed.entries).each do |entry|
        if entry.entry_id =~ /\?t=(\d*)$/
          sfile = { :title     => entry.title, 
                    :srcid     => $1,
                    :srcurl    => entry.entry_id,
                    :date      => entry.published,
                    :category  => feed.title, # entry.categories.join(" ")
                    :other     => {:author => entry.author, :content => entry.content} }
          if entry.summary =~ /Bild: (http:\/\/[^ ]*)/
            sfile[:imageurl] = $1
          end
          usediffy = true
          retries  = 0
          begin
            object = SFile.where(:srcid => sfile[:srcid]).first_or_initialize(sfile)
            if object.new_record? 
              #object.image = URI.parse(object.imageurl) unless object.imageurl.nil?
            else
              if usediffy && object.other[:content].size != sfile[:other][:content].size
                printf "%p != %p\n", object.other[:content].size, sfile[:other][:content].size
                sfile[:diff] = Diffy::Diff.new(object.other[:content], sfile[:other][:content], :context => 1).to_s(:html) 
              end
              object.attributes = sfile
              #object.image = URI.parse(object.imageurl) if object.imageurl_changed? && !object.imageurl.nil?
            end
            @@stats[feed.feed_url][:last][(object.new_record? ? :new : :updated)] += 1 if object.new_record? || object.changed?
            printf "\t%s %s %s / %s %s: %s %s %p %p\n",  object.new_record? ? "(NEW)" : (object.changed? ? "(UPD)" : "(OLD)"),
                                                      object.category,
                                                      object.date.strftime("%d.%m.%y %a %H:%M"),
                                                      entry.last_modified.strftime("%d.%m.%y %a %H:%M"),
                                                      object.other[:author],
                                                      object.title,
                                                      object.srcid,
                                                      object.other.keys,
                                                      object.changes.keys
            if object.new_record? || object.changed?
              object.save 
              puts entry.content.size
              puts object.other[:content].size
            end
          rescue Timeout::Error
            if sfile.include?(:image)
              puts "### Timeout while fetching #{sfile[:image]}"
              sfile.delete(:image)
              retries += 1
              retry unless retries > 1
            end
          rescue => e
            puts e.message
            puts e.backtrace
            puts Diffy::Diff.new(object.other[:content], sfile[:other][:content], :context => 1).to_s(:color)
            usediffy = false
            retries += 1
            retry unless retries > 1
          end
        end
      end
      @@stats[feed.feed_url][:total][:updated] += @@stats[feed.feed_url][:last][:updated]
      @@stats[feed.feed_url][:total][:new]     += @@stats[feed.feed_url][:last][:new]
     rescue => e
       puts e.message
       puts e.backtrace
     end
     nil
    end
  end
  
  def self.boerseupdate
    BoerseSource.new
  end
  
end