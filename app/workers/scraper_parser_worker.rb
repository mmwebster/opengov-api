require 'json'
require 'nokogiri'
require 'open-uri'

class ScraperParserWorker
  include Sidekiq::Worker

  def perform(url)

    parse_tables(url)

    web_statuses = WebStatus.where(url: url)
    if not web_statuses.empty?
      web_status = web_statuses.first
      web_status.write_attribute(:is_parsed, true)
      web_status.save
    end
  end


#############Parser work is done below###########
def key_string_clean(string)
  # convert to lower case
  string = string.downcase
  # replace spaces with dashes
  string.gsub!(' ', '-')
  # return
  string
end

def string_clean(string)
  # convert to lower case
  string = string.downcase
  # return
  string
end

def value_clean(string)
  str_data = { 'value': nil, 'type': nil }
  if string =~ /\d/
    # string contains digits, convert to float
    str_data['value'] = string.to_f
    str_data['type'] = 'float'
  else
    # string contains no digits, convert to lower-case
    str_data['value'] = string_clean(string)
    str_data['type'] = 'string'
  end
  str_data
end

def parse_tables(url)

  if(url == nil || url == '') then
    logger.info "Error reading given URL (nil)"
    return []
  end

  page_noko = Nokogiri::HTML(open(url))
  page_tables = page_noko.css('table')

  table_hashes = []
  table_counter = 1

  # For each table on the page...
  page_tables.each do |table|

    $potential_bad_table_data = "The table was read in successfully"

    table_headers = []

    # A header row is defined as a row which: is not anywhere inside a
    # tbody element; contains two or more th children; and is not empty
    table_rows = table.css('tr')

    # Calculate the number of header rows at the tanle's top
    num_header_rows = 0
    table_rows.map do |row|
      if(row.css('th').length > 1) then
        num_header_rows += 1
      else
        break
      end
    end

    num_body_rows = table_rows.length - num_header_rows

    #logger.info "==========================================================================================="
    #logger.info "Begin processing table \##{table_counter.to_s.rjust(2, '0')}"
    #logger.info "Table \##{table_counter.to_s.rjust(2, '0')}: total number of rows: #{table_rows.length}"
    #logger.info "Table \##{table_counter.to_s.rjust(2, '0')}: number of header rows: #{num_header_rows}"
    #logger.info "Table \##{table_counter.to_s.rjust(2, '0')}: number of body rows: #{num_body_rows}"


    $span_check = []
    $final_span = 0
    table_header_array = [[],[]]

    for i in 0..(num_header_rows - 1)

      $span_check [i] = 0

      #Goes through header rows finding th number
      table_rows[i].css("th").each_with_index do |check|

        colspan = check["colspan"]
        if (colspan.to_i > 1) && (check.text != nil)
          #go through the full width of the col span adding it to each required column index
          for k in ($span_check[i]..colspan.to_i + $span_check[i] - 1)
            #Append current text from current column into all subsequent lower rows
            for j in i ..(num_header_rows - 1)
              if table_header_array[j][k].to_s == ""
                table_header_array[j][k] = "#{check.text}"
              else
                table_header_array[j][k] = "#{table_header_array[j][k].to_s}.#{check.text}"
              end
              # NOTE: this isn't doing anything
              value_clean(table_header_array[j][k])
            end
          end

          #This counts the number of col spans in this row. Incase they wind up different, choose largest
          $span_check[i] +=  + colspan.to_i

        else
          #No phrase col span found or is exactly 1, let both increment by 1
          #first insert current phrase at location and append to all subsequent rows beneath
          for j in i ..(num_header_rows - 1)
            if table_header_array[j][$span_check[i]].to_s == ""
              table_header_array[j][$span_check[i]] = "#{check.text}"
            else
              table_header_array[j][$span_check[i]] = "#{table_header_array[j][$span_check[i]].to_s}.#{check.text}"
            end
            # NOTE: this isn't doing anything
            value_clean(table_header_array[j][$span_check[i]])
          end
          $span_check[i] = $span_check[i] + 1
        end
      end

      #final_span is the # of columns to search through
      if $final_span < $span_check[i]
        $final_span = $span_check[i]
      end
    end

    table_data = Array.new(num_body_rows){Array.new($final_span)}
    datum = Array.new(num_body_rows){Array.new($final_span)}

    for i in 0..(num_body_rows - 1)

      body_index = i + num_header_rows
      has_header = table_rows[body_index].css("th")
      row_data = table_rows[body_index].css("td")

      for j in 0..($final_span - 1)

        col_header = table_header_array[num_header_rows - 1][j]
        cell_value_data = {}

        if row_data[j] == nil
          table_data[i][j] =  body_index, ""

        #contains a header on left side, append to each table head of the column
        elsif has_header[0].to_s != ""

          col_header = "#{col_header}.#{has_header[0].text}"
          # NOTE: This isn't doing anything
          value_clean(col_header)

          #Row data != num of columns, null spaces make it hard to align data
          if row_data.length != ($final_span - 1)
            $potential_bad_table_data = "The table was irregular and could contain incorrect data"
          end

          #Store all table data now
          if j != 0
            table_data[i][j] = body_index, "#{row_data[j-1].text}"
          else
            table_data[i][j] = body_index, ""
          end

          # NOTE: This isn't doing anything
          value_clean(table_data[i][j][1])

        #no head found, just do it normally
        else
          #Row data != num of columns, null spaces make it hard to align data
          if row_data.length != $final_span
            $potential_bad_table_data = "The table was irregular and could contain incorrect data"
          end
          table_data[i][j] = body_index, "#{row_data[j].text}"
          cell_value_data = value_clean(table_data[i][j][1])
          # table_data[i][j][1] = string_clean(table_data[i][j][1])
        end

        value_s = nil
        value_f = nil

        # set string or numeric value
        if cell_value_data['type'] == 'string'
          value_s = cell_value_data['value']
        elsif cell_value_data['type'] == 'float'
          value_f = cell_value_data['value']
        end

        datum[i][j] = WebDatum.create( url: url,
                                       key: key_string_clean(col_header),
                                       value_s: value_s,
                                       value_f: value_f )
      end
    end

    num_body_rows.times do |i|
      datum[i].each do |web_datum|
        datum[i].each do |other_web_datum|
          if not web_datum.id.equal? other_web_datum.id
            web_datum.related_keys << other_web_datum
          end
        end
      end
    end

    table_counter += 1
    #logger.info "\n#{$potential_bad_table_data}\n"

  end
end



end

# call async with ScraperParserWorker.perform_async(<url>)
