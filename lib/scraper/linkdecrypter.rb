# -*- encoding : utf-8 -*-

# http://linkdecrypter.com
# http://dcrypt.it



module Scraper
  
  class Linkdecrypter
    def initialize
      @mech = Mechanize.new do |agent| 
        agent.log = Logger.new('/tmp/mechanize.log')
        agent.user_agent_alias = 'Windows IE 9'
        agent.open_timeout = 30
        agent.read_timeout = 30
        agent.follow_meta_refresh = true
      end
    end
    
    def mech
      @mech
    end
    
    def link(url=1,&block)
      page = @mech.get(ENV['LINKDECRYPTER_URL'])
      form = page.form('f')
      p form
      form.radiobutton_with(:value => /link/).check
      form.checkbox_with(:name => /modo_recursivo/).check
      form.checkbox_with(:name => /link_cache/).check
      form.pro_links = "http://www.relink.us/f/46c59f2cddffee36ad7ccd885b2fc5"
      page = @mech.submit(form)
      sleep(5)
      page = @mech.get(ENV['LINKDECRYPTER_URL'])
      #puts page
      #spoilerlinks = page.search("//div[@class='alt1 messagearea-wrap']/descendant::div[@class='body-spoiler']/descendant::a[@target='_blank']")
      #sharelinks   = page.search("//div[@class='alt1 messagearea-wrap']/descendant::a[@target='_blank']").each{|l| puts l.attributes['href'].value if l.attributes['href'].value =~ /share-links.biz/}
      #page.search("//div[@class='alt1 messagearea-wrap']/descendant::a[@target='_blank']").select{|l| l.attributes['href'].value =~ /share-links.biz/},
      #yield page.search("//div[@class='alt1 messagearea-wrap']/descendant::div[@class='body-spoiler']") if block_given?
      #yield page.search("//div[@class='alt1 messagearea-wrap']") if block_given?
    end
  end
  
  
  
  # def self.boerseupdate
  #   BoerseSourceRss.new
  # end
  
end