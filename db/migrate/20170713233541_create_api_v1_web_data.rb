class CreateApiV1WebData < ActiveRecord::Migration[5.1]
  def change
    create_table :api_v1_web_data do |t|

      t.timestamps
    end
  end
end
