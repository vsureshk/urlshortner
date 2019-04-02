class CreateShortenedUrlAnalytics < ActiveRecord::Migration[5.2]
  def change
    create_table :shortened_url_analytics do |t|
      t.belongs_to :shortened_url, index: true
      t.string :country
      t.string :ip_address

      t.timestamps
    end
  end
end
