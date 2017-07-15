class CreateWebData < ActiveRecord::Migration[5.1]
  def change
    create_table :web_data do |t|
      t.string :key
      t.string :value_s
      t.integer :value_i
      t.float :value_f
      # t.references :related_keys, foreign_key: true
      t.references :web_data, foreign_key: true

      t.timestamps
    end
  end
end
