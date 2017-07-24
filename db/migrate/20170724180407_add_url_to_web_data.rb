class AddUrlToWebData < ActiveRecord::Migration[5.1]
  def change
    add_column :web_data, :url, :string
  end
end
