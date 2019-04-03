FactoryBot.define do
  factory :shortened_url_analytic do
    shortened_url
    id 1
    country Faker::Address.country_by_code(code: 'IN')
    ip_address Faker::Internet.ip_v4_address
    created_at Faker::Time.between(DateTime.now - 1, DateTime.now)
    updated_at Faker::Time.between(DateTime.now - 1, DateTime.now)
  end
end
