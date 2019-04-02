FactoryBot.define do
  factory :shortened_url do
    id 1
    original_url 'https://paper.dropbox.com/doc/Build-a-URL-shortener-BdG2JwuLz5jG4ke1kf4Ye'
    short_url 'qoi12'
    sanitize_url 'http://paper.dropbox.com/doc/build-a-url-shortener-bdg2jwulz5jg4ke1kf4ye'
    expiry_date DateTime.now.next_month
    clicks_count 0
    created_at Faker::Time.between(DateTime.now - 1, DateTime.now)
    updated_at Faker::Time.between(DateTime.now - 1, DateTime.now)
  end
end
