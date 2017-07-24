require 'json'
require 'nokogiri'
require 'open-uri'

class ScraperParserWorker
  include Sidekiq::Worker

  def perform(url)

    #########Begin of parse calls############

    logger.info "\nStarting to Parse!\n\n"
    #parse_tables(url)
    logger.info "\nEnding to parse!\n\n"


    Rails.logger "Im trying to do shit!"
    Rails.logger.info "Im trying to do shit!"

    Sidekiq::Logging.logger "Im trying to do shit!"
    Sidekiq::Logging.logger.info "Im trying to do shit!"

    logger.debug "Trying to do shit"

    print "Trying to do shit"

    puts "Another attempt"


    #########End of parse calls############

    web_statuses = WebStatus.where(url: url)
    if not web_statuses.empty?
      web_status = web_statuses.first
      web_status.write_attribute(:is_parsed, true)
      web_status.save
    end
  end


#############Parser work is done below###########


end

# call async with ScraperParserWorker.perform_async(<url>)
