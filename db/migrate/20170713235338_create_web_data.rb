class CreateWebData < ActiveRecord::Migration[5.1]
  def change
    create_table :web_data do |t|

      t.timestamps
    end
  end
end
