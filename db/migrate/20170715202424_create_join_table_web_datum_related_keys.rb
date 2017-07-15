class CreateJoinTableWebDatumRelatedKeys < ActiveRecord::Migration[5.1]
  def change
    create_table :web_datum_related_keys do |t|
      t.integer :web_datum_id
      t.integer :related_key_id
    end
  end
end
