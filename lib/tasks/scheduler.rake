desc "This task is called by the Heroku scheduler add-on"

task :update_entrants => :environment do
  Scraper::torrentupdate
  puts "done."
end
