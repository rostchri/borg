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
            sfile[:thumbnail] = URI.parse($1)
            sfile[:other][:thumbnail] = $1
          end
          changed  = false
          usediffy = true
          retries  = 0
          begin
            if dbsfile = SFile.find_by_srcid(sfile[:srcid])
              if changed = dbsfile.other[:content] != sfile[:other][:content]
                if usediffy
                  sfile[:other][:changes] = Diffy::Diff.new(dbsfile.other[:content], sfile[:other][:content], :context => 1).to_s(:html) 
                else
                  sfile[:other][:changes] = "ERROR"
                end
              end
            end
            if dbsfile.nil? || changed
              newobject = SFile.where(:srcid => sfile[:srcid]).first_or_create!(sfile)
              @@stats[feed.feed_url][:last][(changed ? :updated : :new)] += 1
            end
          rescue Timeout::Error
            if sfile.include?(:thumbnail)
              puts "### Timeout while fetching #{sfile[:thumbnail]}"
              sfile.delete(:thumbnail)
              retries += 1
              retry unless retries > 1
            end
          rescue => e
            puts e.message
            puts e.backtrace
            puts Diffy::Diff.new(dbsfile.other[:content], sfile[:other][:content], :context => 1).to_s(:color)
            usediffy = false
            retries += 1
            retry unless retries > 1
          end
          unless newobject.nil?
            printf "\t%s %p %s / %s %s: %s [%s] (%p) (%p)\n",  dbsfile.nil? ? "(NEW)" : (changed ? "(UPD)" : "(OLD)"),
                                                     newobject.category,
                                                     newobject.date.strftime("%d.%m.%y %a %H:%M"),
                                                     entry.last_modified.strftime("%d.%m.%y %a %H:%M"),
                                                     newobject.other[:author],
                                                     newobject.title,
                                                     newobject.srcid,
                                                     newobject.other[:changes].nil? == false,
                                                     newobject.changed?
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