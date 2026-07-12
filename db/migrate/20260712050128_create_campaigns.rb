class CreateCampaigns < ActiveRecord::Migration[8.1]
  def change
    create_table :campaigns do |t|
      t.string :name
      t.string :slug
      t.string :original_url
      t.integer :campaign_type
      t.datetime :starts_at
      t.datetime :ends_at
      t.integer :clicks_count

      t.timestamps
    end
    add_index :campaigns, :slug, unique: true
  end
end
