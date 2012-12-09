# -*- encoding : utf-8 -*-
require 'mechanize'
# http://sixserv.org/2009/05/27/webscripting-mit-ruby-und-mechanize/

module Scraper
  
  
  class TorrentSource
    VALID_GROUP_NAMES = ["Filme", "TV - Serien", "TV - Shows", "TV - Dokus", "Bücher - eBooks", "Bücher - Hörspiele und Hörbücher"]
        
    def initialize
      @days    = {}
      @timeout = 30
      @mech    = Mechanize.new do |agent| 
        agent.log = Logger.new('/tmp/mechanize.log')
        agent.user_agent_alias = 'Windows IE 9'
        agent.open_timeout = 30
        agent.read_timeout = 30
        # agent.pre_connect_hooks << lambda do |agent,params|
        #   # printf "%p\n", agent
        #   # printf "%p\n", params
        #   #params[:request]['Referer'] = 'http://torrent.to/torrent.php'
        # end
      end
      
      @ajaxmech = Mechanize.new do |agent| 
        agent.log = Logger.new('/tmp/ajaxmechanize.log')
        agent.user_agent_alias = 'Windows IE 9'
        agent.open_timeout = 3 
        agent.read_timeout = 4
        agent.keep_alive = false # default ist true
        
        agent.pre_connect_hooks << lambda do |params|
          params[:request]['X-Requested-With'] = 'XMLHttpRequest'
          # params[:request]['Accept-Language'] = 'de-de'
          printf "%p\n", agent
          printf "%p\n", params
        end
      end
      
    end

    def mech
      @mech
    end
    
    def ajaxmech
      @ajaxmech
    end
    
    def days
      @days
    end

    def detail(id)
      printf "Fetching details %d\n", id
      page = @mech.get "http://torrent.to/torrent.php", 
                           {'Mod' => 'Details', 'ID' => id}, 
                           'http://torrent.to/torrent.php',
                           {'Accept-Language' => 'de-de'}
      res = {}
      res[:title]       = page.at("//div[@id='Mainframe']/descendant::div[@class='Headline']/table").content
      res[:thumbnail]   = "http://torrent.to/" + page.at("//div[@id='Mainframe']/descendant::div[@id='MainDet']/descendant::img[@class='Thumbnail']").attributes['src'].value
      res[:description] = page.at("//div[@id='Mainframe']/descendant::div[@id='MainDet']/descendant::div[@class='TDe_Descr']").content
      res[:size]        = page.at("//div[@id='Mainframe']/descendant::div[@class='Size Torrents']").content
      res[:magnetlink]  = page.search("//div[@id='Mainframe']/descendant::div[@class='Get Torrents']/a").select{|l| l.content=="Magnet"}.first.attributes['href'].value
      res[:comments]    = page.search("//div[@id='Mainframe']/descendant::div[@id='Comments']/div[@class='Comment']").map{|c| c.at("div[@class~='User']").content + c.at("div[@class~='UserComment']").content }
      res
    end

    def dayindex(pastdays=0)
      ajax_headers = { 'Origin' => 'http://torrent.to',
                       'Referer' => 'http://torrent.to/torrent.php',
                       'Accept-Language' => 'de-de',
                       'Accept-Encoding' => 'gzip, deflate',
                       'X-Requested-With' => 'XMLHttpRequest', 
                       'Content-Type' => 'application/x-www-form-urlencoded', 
                       'Accept' => 'application/json, text/javascript, */*' }
      days = {}
      @days.each do |date,day|
        if ((Date.today - date).to_i <= pastdays) && day[:data].nil?
          printf "%p:\n", date
          params = "Request=GetNewsContent&Timestamp=#{day[:timestamp]}"
          response = @mech.post( 'http://torrent.to/res/php/Ajax.php', params, ajax_headers)
          result = JSON.parse(response.content)
          result['Days'].each { |timestamp,date| days[Date.strptime(date,'%d.%m.%Y')] = timestamp.to_i}
          result['Data']["Groups"].each do |groupindex,group|
            day[:data]={} if day[:data].nil?
            if VALID_GROUP_NAMES.include?(group['Name'])
              printf "\t%p\n", group['Name']
              group['Items'].sort do |a,b| 
                  ((b['Tip']=='1' ? 1 : 0)  <=> (a['Tip']=='1' ? 1 : 0)).nonzero? ||
                  (b['Leecher']             <=> a['Leecher']).nonzero? ||
                  (b['Seeder']              <=> a['Seeder']).nonzero? ||
                  (a['Title']               <=> b['Title']).nonzero? ||
                  1
                end.each do |item|
                  day[:data][group['Name']]=[] if day[:data][group['Name']].nil?
                  day[:data][group['Name']] << i = { :title  => item['Title'], 
                        :id     => item['ID'].to_i, 
                        :tip    => item['Tip']=='1', 
                        :format => item['Detail'].nil? || item['Detail']==false ? '' : "#{item['Detail']}",
                        :stats  => item['Seeder']=="0" && item['Leecher']=="0" ? '' : "(S/L: #{item['Seeder']}/#{item['Leecher']})",
                  }
                  printf "\t\t%1.1s #%-8.8s %p %s %s\n", i[:tip] ? ">" : "",i[:id],i[:title],i[:format].empty? ? '' : "[#{i[:format]}]",i[:stats]
              end
            end
          end
        end
      end
      
      days.each do |date,timestamp|
        if @days[date].nil?
          @days[date] = {:timestamp => timestamp} 
          printf "Timestamp for %p (%p) added\n", date, timestamp
        end
      end
      
      # fetch details
      @days.each do |date,day|
        if !day[:data].nil? && (Date.today - date).to_i <= pastdays
          day[:data].each do |groupname,items|
            printf "Fetching details for %p %p\n", date, groupname
            items.each do |item|
              if Torrent.find_by_srcid(item[:id]).nil?
                item.merge!(detail(item[:id]))
                Torrent.create :title => item[:title], 
                               :srcid => item[:id],
                               :timestamp => date,
                               :detail => item.clone.delete_if {|key, value| [:title,:id,].include?(key) }
              end
            end
          end
        end
      end


      # print all with details
      @days.each do |date,day|
        if !day[:data].nil? && (Date.today - date).to_i <= pastdays
          printf "%p:\n", date
          day[:data].each do |groupname,items|
            printf "\t%p\n", groupname
            items.each do |i|
              printf "\t\t%1.1s #%-8.8s %p %s %s %s\n", i[:tip] ? ">" : "",i[:id],i[:title],i[:format].empty? ? '' : "[#{i[:format]}]",i[:stats], i[:size]
            end
          end
        end
      end      
      
      nil
    end
    
    def mainindex
      begin
        Timeout::timeout(@timeout) do
          page = @mech.get('http://torrent.to/torrent.php')
          # loop over all AJ_Request-Links
          page.search("//*[@*[contains(., 'AJ_Request')]]").each do |ajaxlink| 
            unless ajaxlink.attributes['onclick'].nil?
              if ajaxlink.attributes['onclick'].value =~ /AJ_Request\('GetNewsContent', '(\d*)'\);/
                date = Date.strptime(ajaxlink.content,'%d.%m.%Y')
                if @days[date].nil?
                  @days[date] = {:timestamp => $1.to_i}
                  printf "Timestamp for %p (%d) added\n", date, $1.to_i
                end
              end
            end
          end
        end
      end
      #page
      nil
    end
  end
  
  
  def self.torrentupdate
    torrentsource = TorrentSource.new
    torrentsource.mainindex
    torrentsource.dayindex(4)
  end
  
    
end