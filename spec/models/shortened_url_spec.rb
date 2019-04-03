require 'rails_helper'

RSpec.describe ShortenedUrl, :type => :model do

  context "Associations" do
    it { should have_many(:shortened_url_analytics).dependent(:destroy) }
  end

  context "Types" do
    it do
      should have_db_column(:id).of_type(:integer)
      should have_db_column(:original_url).of_type(:text)
      should have_db_column(:short_url).of_type(:string)
      should have_db_column(:sanitize_url).of_type(:string)
      should have_db_column(:expiry_date).of_type(:datetime)
      should have_db_column(:clicks_count).of_type(:integer).with_options(default: 0)
      should have_db_column(:created_at).of_type(:datetime).with_options(null: false)
      should have_db_column(:updated_at).of_type(:datetime).with_options(null: false)
    end
  end

  context "Validations" do
    it { should validate_uniqueness_of(:original_url) }
    it { should validate_presence_of(:original_url) }
  end

   let!(:shortened_url) { FactoryBot.create(:shortened_url) }

    it "is valid with valid attributes" do
      expect(shortened_url).to be_valid
    end

end