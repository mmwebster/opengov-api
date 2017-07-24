class Api::V1::WebStatusesController < JSONAPI::ResourceController

  # start scraper/parser job if url hasn't been parsed
  after_action do
    # check if request for specific url status
    # (endpoint api/v1/web-statuses?filter[url]=<url>)
    if request.params['filter']
      # check if no matching record was found
      matched_record = JSON.parse(response.body)['data'][0]
      if not matched_record
        url = request.params['filter']['url']
        # insert a web status record for this url to indicate parsing
        #WebStatus.create(url: url, is_parsed: false)
        # start scraper/parser job since url not parsed
        ScraperParserWorker.perform_async(url)
      end
    end
  end
end
