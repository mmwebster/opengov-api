class ScraperParserWorker
  include Sidekiq::Worker

  def perform(url)
    # Parser/Worker implementation here
    # ...
    sleep(5)
    web_statuses = WebStatus.where(url: url)
    if not web_statuses.empty?
      web_status = web_statuses.first
      web_status.write_attribute(:is_parsed, true)
      web_status.save
    end
  end

end

# call async with ScraperParserWorker.perform_async(<url>)
