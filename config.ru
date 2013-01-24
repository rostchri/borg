# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)

use Rack::ReverseProxy do  
	reverse_proxy_options :preserve_host => true
	reverse_proxy /^\/entrants\/\d+\/[^\/]*\/decrypt(\/.*)$/, 'http://linkdecrypter.com$1' do |body,headers,rackreq|
		# puts "Reverse Request Headers: #{headers.inspect}"
		# puts "FUL-URL: #{rackreq.fullpath}"
		if rackreq.fullpath =~ /^\/entrants\/(\d+)\/([^\/]*)\/decrypt\/$/ 
			entrant = $1.to_i 
			url = Base64::urlsafe_decode64($2)
			#puts "ENTRANT: #{entrant} URL: #{url}"
			page = Nokogiri::HTML(body)
			
			# on first page set url to decrypt and set link-mode
			page.xpath("//textarea[@name='pro_links']").each {|textarea| textarea.content=url} #unless url.nil? || url.empty?
			page.xpath("//input[@id='text_mode']").each { |input| input.remove_attribute('checked') } 
			page.xpath("//input[@id='link_mode']").each { |input| input.set_attribute('checked', 'checked') } 
			
			# on last page extract urls and save to database
			links = []
			page.xpath("//pre[@class='enlaces']/a[@target='_blank']").each { |link| links << link.attributes['href'].value }
			if !links.empty? && entrant = Entrant.find(entrant)
				entrant.links = links
				entrant.save
			end
			
			page.to_s
		else
			body
		end
  end
end


run Borg::Application
