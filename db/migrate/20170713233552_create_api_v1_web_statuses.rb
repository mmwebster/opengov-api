class CreateApiV1WebStatuses < ActiveRecord::Migration[5.1]
  def change
    create_table :api_v1_web_statuses do |t|

      t.timestamps
    end
  end
end
