class CreateWebStatuses < ActiveRecord::Migration[5.1]
  def change
    create_table :web_statuses do |t|
      t.string :url
      t.boolean :is_parsed

      t.timestamps
    end
  end
end
