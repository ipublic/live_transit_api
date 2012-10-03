class CreateAgencies < ActiveRecord::Migration
  def change
    create_table :agencies do |t|
      t.string :agency_id, :limit => 255, :null => true
      t.string :agency_name, :limit => 512, :null => false
      t.string :agency_url, :limit => 1024, :null => false
      t.string :agency_timezone, :limit => 255, :null => false
      t.string :agency_lang, :limit => 255, :null => true
      t.string :agency_phone, :limit => 255, :null => true
      t.string :agency_fare_url, :limit => 1024, :null => true
    end

    add_index :agencies, :agency_id, :unique => true
    add_index :agencies, :agency_name
  end
end
