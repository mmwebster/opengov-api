class Api::V1::WebDatumResource < JSONAPI::Resource
  attributes \
    :key,
    :value_s,
    :value_i,
    :value_f

  has_many :web_data #, foreign_key_on: :self
                     # Add ^ if not working
end
