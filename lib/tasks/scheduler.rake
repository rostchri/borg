# heroku run rake update_entrants
# heroku addons:open scheduler
# heroku logs --ps scheduler.1

desc "This task is called by the Heroku scheduler add-on"

task :update_entrants => :environment do
  Movie.where("c00_soundex is NULL OR c00_soundex = ''").each { |m| m.update_attribute :c00_soundex, Movie.soundex(m.localtitle) }
  Scraper::torrentupdate(1)
  Scraper::boerseupdate
  Entrant.recycle
  puts "done."
end
