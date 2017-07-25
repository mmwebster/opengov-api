class Api::V1::WebDatumResource < JSONAPI::Resource
  attributes \
    :key,
    :value_s,
    :value_i,
    :value_f,
    :url

  has_many :web_data #, foreign_key_on: :self
                     # Add ^ if not working

  def self.clean_string(str)
    # strip surrounding quotations
    if str.first == "'"
      str.remove("'")
    end
    # escape special chars
    # TODO: escape while ensuring no conflicts with multi-word values
    str # return
  end

  # TRUE if word the first in a param "value" field
  def self.word_is_value_start(word)
    word.first == "'" and word.last != "'"
  end

  # TRUE if word the last in a param "value" field
  def self.word_is_value_end(word)
    word.first != "'" and word.last == "'"
  end

  # parse a SELECT param
  def self.parse_select_param(word,
                              current_keyword,
                              parsed_query,
                              context_binding)
    word = clean_string(word)
    eval "parsed_query[:#{current_keyword}].append(%q[#{word}])", context_binding
  end

  # parse a FROM param
  def self.parse_from_param(word,
                            current_keyword,
                            parsed_query,
                            context_binding)
    word = clean_string(word)
    eval "parsed_query[:#{current_keyword}].append(%q[#{word}])", context_binding
  end

  # parse a WHERE param
  def self.parse_where_param(word,
                             current_keyword,
                             parsed_query,
                             context_binding)
    # init param stack and other instance vars
    @param_stack ||= []
    @value_pending ||= false

    # append word or concatenate to previous word
    if word_is_value_start(word) and not @value_pending
      # word is start of value, mark as such then handle normally
      @value_pending = true
      @param_stack.append(clean_string(word))
    elsif word_is_value_end(word)
      # word is end of value, mark as such then concatenate
      @value_pending = false
      @param_stack.last << " #{word}"
    elsif @value_pending
      # word is inner member of value, concatenate
      @param_stack.last << " #{word}"
    else
      # word is singleton
      @param_stack.append(clean_string(word))
    end

    # if full param received, pop previous two vals and insert param
    # to structured query data
    if @param_stack.length == 3 and not @value_pending
      value = @param_stack.pop()
      operator = @param_stack.pop()
      key = @param_stack.pop()
      # add data to structured/parsed query data
      injection_statement = "parsed_query[:#{current_keyword}].append({" \
                            "key: %q[#{key}], operator: %q[#{operator}]" \
                            ", value: %q[#{value}] })"
      eval injection_statement, context_binding
    end
  end

  def self.parse_query(query_str)
    parsed_query = { 'SELECT': [], 'FROM': [], 'WHERE': [] }
    sql_param_parsers = {
      'SELECT': method(:parse_select_param),
      'FROM': method(:parse_from_param),
      'WHERE': method(:parse_where_param)
    }
    query_words = query_str.split
    current_keyword = nil

    # iterate through words in
    query_words.each do |word|
      # set keyword
      is_keyword = sql_param_parsers.key? word.upcase.to_sym
      if is_keyword
        current_keyword = word
        next # don't process the word, it's a keyword
      end
      # parse and insert data based on param (word)
      puts "DEBUG => Parsing param=#{word}, current_keyword=#{current_keyword}"
      sql_param_parsers[current_keyword.to_sym].call( word,
                                                      current_keyword,
                                                      parsed_query,
                                                      binding )
    end
    parsed_query # return
  end

  # TODO: Create url-specific endpoint to prevent loading of ALL records EVER
  # filter datum records by sql-syntax query (format is "?filter[query]=<query>")
  # filter :query, apply: method(:parse_wrapper) #(records, value, _options)
  filter :query, apply: ->(records, value, _options) {
    # attempt to parse the query
    begin
      parsed_query = parse_query(value[0])
    rescue Exception => e
      # catch exceptions during parsing
      puts "*******ERROR: FAILURE on #{e.to_s}"
      # return empty response
      return records.where(id: 0)
    end
    # TODO: perform logical error checking on structured query
    # ...

    top_level_matches = records.where(
      key: parsed_query[:SELECT].first,
      url: parsed_query[:FROM].first.split("'").last,
    )
    # filter these records by their associations
    association_matches = []
    top_level_matches.each do |record|
      # For each top level match, check it's assocations for
      # association-level matches
      record.related_keys.each do |related_record|
        criteria = parsed_query[:WHERE].first # just use the first one for now
        is_key = eval "related_record.key == \'#{criteria[:key]}\'"
        if is_key
          # TODO: More intelligent numeric detection
          # TODO: Escaping/cleaning -> this is highly susceptible to injection
          # compute type of user-provided value
          value_types = criteria[:value] =~ /\d/ ? ["value_i", "value_f"] : ["value_s"]
          value_types.each do |value_type|
            # clean value into useable value
            value_map = { value_i: ->(v) {v.to_i},
                          value_f: ->(v) {v.to_f},
                          value_s: ->(v) {v} }
            value = value_map[value_type.to_sym].call(criteria[:value])
            # check if this value type is defined for the current rel. record
            record_has_value_type = eval "related_record.#{value_type}"
            if record_has_value_type
              # check if the related_record passes this criterium
              matches_value = eval "related_record.#{value_type} " \
                                   "#{criteria[:operator]} #{value}"
              if matches_value
                # Push the original record to the final list that will
                # be returned to the user
                association_matches.append(record)
                next
              end
            end
          end
        end
      end
    end
    # translate array of records into ActiveRecord::Relation and return
    # TODO: Use latest ActiveRecord::Relation syntax instead of this
    #       brute force and computationally expensive method
    records.where(id: association_matches.map(&:id))
  }

end
