FactoryBot.define do
  factory :shortened_url do
    id 1
    original_url Faker::Internet.url('example.com', '/foobar.html')
    short_url 'qoi12'
    sanitize_url Faker::Internet.url('example.com', '/foobar.html')
    expiry_date DateTime.now.next_month
    clicks_count 0
    created_at Faker::Time.between(DateTime.now - 1, DateTime.now)
    updated_at Faker::Time.between(DateTime.now - 1, DateTime.now)
  end

  factory :shortened_url1, class: ShortenedUrl do
    id 2
    original_url Faker::Internet.url('google.com', '/foobar.html')
    short_url 'qoi13'
    sanitize_url Faker::Internet.url('google.com', '/foobar.html')
    expiry_date DateTime.now - 30
    clicks_count 0
    created_at DateTime.now - 60
    updated_at DateTime.now - 28
  end
end
