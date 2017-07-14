class CreateWebStatuses < ActiveRecord::Migration[5.1]
  def change
    create_table :web_statuses do |t|

      t.timestamps
    end
  end
end
