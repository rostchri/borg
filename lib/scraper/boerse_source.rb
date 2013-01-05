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
            sfile[:other].merge!(:thumbnail => $1)
            sfile[:thumbnail] = URI.parse($1)
          end
          changed = false
          if dbsfile = SFile.find_by_srcid(sfile[:srcid])
            changed = dbsfile.other[:content] != sfile[:other][:content]
          end
          usediffy=true
          retries = 0
          begin
            if dbsfile.nil? || changed
              newobject = SFile.find_or_create_by_srcid(sfile[:srcid]) {|newsfile| sfile.each {|k,v| newsfile.send("#{k}=",v)}}
              @@stats[feed.feed_url][:last][(dbsfile.nil? ? :new : :updated)] += 1
              unless dbsfile.nil?
                newobject.category  = feed.title +  " " + entry.categories.join(" ")
                newobject.thumbnail = URI.parse(sfile[:other][:thumbnail]) unless sfile[:other][:thumbnail].nil? || sfile[:other][:thumbnail].empty?
                newobject.other[:thumbnail] = sfile[:other][:thumbnail]
                newobject.other[:content]   = sfile[:other][:content]
                newobject.other[:changes]   = Diffy::Diff.new(dbsfile.other[:content], sfile[:other][:content]).to_s(:html) if usediffy
                newobject.save
              end
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
            puts Diffy::Diff.new(dbsfile.other[:content], sfile[:other][:content]).to_s(:color)
            usediffy=false unless dbsfile.nil?
            retries += 1
            retry unless retries > 1
          end
          printf "\t%s %p %s / %s %s: %s [%s]\n",  dbsfile.nil? ? "(NEW)" : (changed ? "(UPD)" : "(OLD)"),
                                                   sfile[:category],
                                                   sfile[:date].strftime("%d.%m.%y %a %H:%M"),
                                                   entry.last_modified.strftime("%d.%m.%y %a %H:%M"),
                                                   sfile[:other][:author],
                                                   sfile[:title],
                                                   sfile[:srcid]
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