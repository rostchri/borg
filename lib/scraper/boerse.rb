# -*- encoding : utf-8 -*-
require 'feedzirra'

# http://linkdecrypter.com
# http://dcrypt.it


class String
  def to_ascii
    # split in muti-byte aware fashion and translate characters over 127 and dropping characters not in the translation hash
    self.chars.collect do |c|
      (c.ord <= 127) ? c : translation_hash[c.ord] 
    end.join
  end
    
  protected
      def translation_hash
        @@translation_hash ||= setup_translation_hash      
      end
      def setup_translation_hash
        accented_chars   = "ÀÁÂÃÄÅÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚÛÜÝàáâãäåçèéêëìíîïñòóôõöøùúûüý"
        unaccented_chars = "AAAAAACEEEEIIIIDNOOOOOxOUUUUYaaaaaaceeeeiiiinoooooouuuuy"
        translation_hash = {}
        accented_chars.chars.each_with_index { |char, idx| translation_hash[char[0]] = unaccented_chars[idx] }
        translation_hash["Æ".ord] = 'AE'
        translation_hash["æ".ord] = 'ae'
        translation_hash["ä".ord] = 'ä'
        translation_hash["ö".ord] = 'ö'
        translation_hash["ü".ord] = 'ü'
        translation_hash["Ü".ord] = 'Ü'
        translation_hash["Ö".ord] = 'Ö'
        translation_hash["Ä".ord] = 'Ä'
        translation_hash["ß".ord] = 'ß'
        translation_hash
      end
end

module Scraper
  
  class BoerseSourceWeb
    def initialize
      @days    = {}
      @timeout = 30
      @mech    = Mechanize.new do |agent| 
        #agent.log = Logger.new('/tmp/mechanize.log')
        agent.user_agent_alias = 'Windows IE 9'
        agent.open_timeout = 30
        agent.read_timeout = 30
        # agent.pre_connect_hooks << lambda do |agent,params|
        #    params[:request]['X-Requested-With'] = 'XMLHttpRequest'
        #    params[:request]['Accept-Language'] = 'de-de'
        # end
      end
      
      loginurl = "http://www.boerse.bz/login.php?do=login";
      params   = {  'vb_login_username'         => ENV['BOERSE_USERNAME'], 
                    'vb_login_password'         => ENV['BOERSE_PASSWORD'], 
                    'cookieuser'                => '1',
                    's'                         => '', 
                    'securitytoken'             => 'guest',
                    'do'                        => 'login', 
                    'vb_login_md5password'      => '', 
                    'vb_login_md5password_utf'  => '' }
                    
      response = @mech.post(loginurl, params)
      @mech
    end
    
    def get(url,&block)
      #printf "Fetching %s\n", url
      page = @mech.get url
      #spoilerlinks = page.search("//div[@class='alt1 messagearea-wrap']/descendant::div[@class='body-spoiler']/descendant::a[@target='_blank']")
      #sharelinks   = page.search("//div[@class='alt1 messagearea-wrap']/descendant::a[@target='_blank']").each{|l| puts l.attributes['href'].value if l.attributes['href'].value =~ /share-links.biz/}
      #page.search("//div[@class='alt1 messagearea-wrap']/descendant::a[@target='_blank']").select{|l| l.attributes['href'].value =~ /share-links.biz/},
      #yield page.search("//div[@class='alt1 messagearea-wrap']/descendant::div[@class='body-spoiler']") if block_given?
      yield page.search("//div[@class='alt1 messagearea-wrap']") if block_given?
    end
  end
  
  class BoerseSourceRss
    attr_accessor :feeds
    @@stats = {}
    
    def initialize
      @@stats = {}
      # Feedzirra::Feed.add_common_feed_element('ttl')
      # Feedzirra::Feed.add_common_feed_element('generator')
      # Feedzirra::Feed.add_common_feed_entry_element('ttl')
      @@web  = Scraper::BoerseSourceWeb.new
      repeat = true
      repeat_count = 0
      while repeat && repeat_count < 5 do
        repeat = false
        repeat_count += 1
        @feeds = Feedzirra::Feed.fetch_and_parse ENV['BOERSE_FEEDS'].split(",").map{|id| "#{ENV['BOERSE_FEED_URL']}#{id}"}, 
                                                 :on_success => ->(url, feed) { BoerseSourceRss.items(feed)},
                                                 :on_failure => ->(url, response_code, response_header, response_body) { repeat = true; puts "### ERROR #{url} #{response_header}"}
        sleep 5
      end
      stats
      nil
    end
    
    def update
      @feeds.each do |u,feed|
        unless feed.is_a? Fixnum
          @@stats[feed.feed_url][:last] = {:updated => 0, :new => 0}
          updated_feed = Feedzirra::Feed.update(feed)
          unless updated_feed.is_a? Array
            BoerseSourceRss.items updated_feed, false 
            puts "#{updated_feed.updated?} #{updated_feed.last_modified}"
          end
        end
      end
      stats
      nil
    end
    
    def stats
      total = {:last => {:updated => 0, :new => 0}, :total => {:updated => 0, :new => 0}}
      @feeds.each do |u,feed|
        unless feed.is_a? Fixnum
          total[:last][:new]      += @@stats[feed.feed_url][:last][:new]
          total[:last][:updated]  += @@stats[feed.feed_url][:last][:updated]
          total[:total][:new]     += @@stats[feed.feed_url][:total][:new]
          total[:total][:updated] += @@stats[feed.feed_url][:total][:updated]
          printf "### Zuletzt aktualisiert: %3d neu: %3d Total aktualisiert: %3d neu: %3d ### %s\n",  @@stats[feed.feed_url][:last][:updated], 
                                                                                                      @@stats[feed.feed_url][:last][:new],
                                                                                                      @@stats[feed.feed_url][:total][:updated], 
                                                                                                      @@stats[feed.feed_url][:total][:new],
                                                                                                      feed.title
        else
          puts "### ERROR: #{u} #{feed}"
        end
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
        # at first fix some encoding-problems
        entry.content = entry.content.to_ascii
        entry.title   = entry.title.to_ascii
        entry.author  = entry.author.to_ascii
        
        if entry.entry_id =~ /\?t=(\d*)$/
          sfile = { :title     => entry.title, 
                    :srcid     => $1,
                    :srcurl    => entry.entry_id,
                    :date      => entry.published,
                    :category  => entry.categories.join(" "), #feed.title
                    :content   => entry.content,
                    :author    => entry.author }
          if entry.content =~ /title\/(tt\d{5,8})/
            sfile[:imdbid] = $1
          end
          if entry.summary =~ /Bild: (http:\/\/[^ ]*)/
            sfile[:imageurl] = $1
          end
          if entry.title =~ /^([^\(]*?)[ \(]*((19|20)\d{2})[ \)]*(.*)/
            sfile[:other] = {} if sfile[:other].nil?
            sfile[:other][:movietitle]    = $1
            sfile[:other][:movieyear]     = $2
            sfile[:infos] = $4
          end
          usediffy = true
          retries  = 0
          begin
            object = SFile.where(:srcid => sfile[:srcid]).first_or_initialize(sfile)
            webget = false
            if object.new_record? 
              #object.image = URI.parse(object.imageurl) unless object.imageurl.nil?
              webget = true
            else
              if usediffy && !object.title.nil? && object.title != sfile[:title]
                object.diff << Diffy::Diff.new(object.title, sfile[:title], :context => 1).to_s(:html) 
              end
              if usediffy && !object.content.nil? && object.content != sfile[:content]
                diff = Nokogiri::HTML(Diffy::Diff.new(Nokogiri::HTML(object.content).to_str, Nokogiri::HTML(sfile[:content]).to_str, :context => 1).to_s(:html))
                diff_del = diff.xpath("//li[@class='del']").size
                diff_ins = diff.xpath("//li[@class='ins']").size
                if (diff_del > 0 || diff_ins > 0)
                  object.diff << diff.to_s
                  webget = true
                end
              end
              #object.image = URI.parse(object.imageurl) if object.imageurl_changed? && !object.imageurl.nil?
              unless webget
                sfile[:other] = {} if sfile[:other].nil?
                sfile[:other][:messages] = object.other[:messages] unless object.other[:messages].nil?
              end
            end
            # @@web.get(entry.entry_id) do |spoiler|
            #   unless spoiler.empty?
            #     sfile[:other] = {} if sfile[:other].nil?
            #     sfile[:other][:spoiler] = []
            #     spoiler.each do |i| 
            #       spoiler_content = i.to_s.to_ascii
            #       sfile[:other][:spoiler] << Base64.encode64(spoiler_content)
            #       if sfile[:imdbid].nil?
            #         if spoiler_content =~ /title\/(tt\d{5,8})/
            #           sfile[:imdbid] = $1
            #         end
            #       end
            #     end
            #   end
            # end if webget
            
            
            @@web.get(entry.entry_id) do |messages|
              unless messages.empty?
                sfile[:other] = {} if sfile[:other].nil?
                sfile[:other][:messages] = []
                messages.each do |message| 
                  message_content = message.to_s
                  sfile[:other][:messages] << Base64.encode64(message_content)
                  if sfile[:imdbid].nil?
                    if message_content =~ /title\/(tt\d{5,8})/
                      sfile[:imdbid] = $1
                    end
                  end
                end
              end
            end if webget
            
            object.attributes = sfile
            @@stats[feed.feed_url][:last][(object.new_record? ? :new : :updated)] += 1 if object.new_record? || object.changed?
            printf "\t%s %s %s / %s [%s] %14.14s: %s %p %p\n", object.new_record? ? "(NEW)" : (object.changed? ? "(UPD)" : "(OLD)"),
                                                          object.category,
                                                          object.date.strftime("%d.%m.%y %a %H:%M"),
                                                          entry.last_modified.strftime("%d.%m.%y %a %H:%M"),
                                                          object.srcid,
                                                          object.author,
                                                          object.title,
                                                          object.imdbid, sfile[:imdbid]#,
                                                          # object.changes.keys.map{|i| i.to_sym}
            object.save if object.new_record? || object.changed?
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
            puts Diffy::Diff.new(object.content, sfile[:content], :context => 1).to_s(:color)
            usediffy = false
            retries += 1
            retry unless retries > 1
          end
        end
      end
      @@stats[feed.feed_url][:total][:updated] += @@stats[feed.feed_url][:last][:updated]
      @@stats[feed.feed_url][:total][:new]     += @@stats[feed.feed_url][:last][:new]
     rescue => e
       puts "### EXCEPTION: #{e.message} for feed-entry: #{entry.entry_id} - Skipping this entry"
       puts e.backtrace
     end
     nil
    end
  end
  
  def self.boerseupdate
    BoerseSourceRss.new
  end
  
end