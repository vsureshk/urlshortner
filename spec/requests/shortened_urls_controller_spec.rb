require "rails_helper"

RSpec.describe "ShortenedUrlsController", :type => :request do
  it "GET index" do
    get "/"
    expect(response).to have_http_status 200
    expect(response.content_type).to eq("text/html")
    expect(response).to render_template("index")
  end

  context "GET show" do
    it "It Redirects to original url within a month" do
      short = FactoryBot.create(:shortened_url)
      get "/#{short.short_url}"
      expect(response).to have_http_status 302
      expect(response.content_type).to eq("text/html")
      expect(response).to redirect_to("http://example.com/foobar.html")
    end

    it "It shows 404 Not Found page after a month" do
      short = FactoryBot.create(:shortened_url1)
      get "/#{short.short_url}"
      expect(response).to have_http_status 404
      expect(response.content_type).to eq("text/html")
      expect(response).to render_template(:file => "#{Rails.root}/public/404.html")
    end
  end

  it "GET stats" do
    get "/stats"
    expect(response).to have_http_status 200
    expect(response.content_type).to eq("text/html")
    expect(response).to render_template("stats")
  end

  context "POST create" do
    it "It create short url with valid params" do
      post "/shortened_urls/create", :params => {"shortened_url" =>{"original_url" => "https://www.rubydoc.info/gems/rspec-rails/frames"}, format: :js}
      expect(response).to have_http_status 200
      expect(response.content_type).to eq("text/javascript")
      expect(response).to render_template("create")
    end

    it "It will not create short url with invalid params" do
      short = FactoryBot.create(:shortened_url)
      post "/shortened_urls/create", :params => {"shortened_url" =>{"original_url" => short.original_url}, format: :js}
      expect(response).to have_http_status 200
      expect(response.content_type).to eq("text/javascript")
      expect(response).to render_template("shortened_urls/index")
    end
  end

end
