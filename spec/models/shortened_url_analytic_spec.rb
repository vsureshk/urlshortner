require 'rails_helper'

RSpec.describe ShortenedUrlAnalytic, :type => :model do

  context "Associations" do
    it { should belong_to(:shortened_url) }
  end

  context "Types" do
    it do
      should have_db_column(:id).of_type(:integer)
      should have_db_column(:shortened_url_id).of_type(:integer)
      should have_db_column(:country).of_type(:string)
      should have_db_column(:ip_address).of_type(:string)
      should have_db_column(:created_at).of_type(:datetime).with_options(null: false)
      should have_db_column(:updated_at).of_type(:datetime).with_options(null: false)
    end
  end

   let!(:shortened_url_analytic) { FactoryBot.create(:shortened_url_analytic) }

    it "is valid with valid attributes" do
      expect(shortened_url_analytic).to be_valid
    end

end