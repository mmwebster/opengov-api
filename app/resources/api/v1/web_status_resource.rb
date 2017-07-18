class Api::V1::WebStatusResource < JSONAPI::Resource
  attributes \
    :url,
    :is_parsed

  # filter web_status records by url (format is "?filter[url]=<url>")
  filter :url, apply: ->(records, value, _options) {
    records.where(url: value)
  }
end
