class WebDatum < ApplicationRecord
  # belongs_to :related_keys
  #
  # belongs_to :related_key,
  #            :class_name => "WebDatum",
  #            :foreign_key => "related_key_id"

  # has_many :related_keys, :class_name => "WebDatum",
  #                         :foreign_key => "web_data_id"

  has_and_belongs_to_many :related_keys, class_name: "WebDatum",
                                         join_table: "web_datum_related_keys",
                                         association_foreign_key: "related_key_id"
                                         # foreign_key: "web_data_id"

end
