class ShortenedUrlsController < ApplicationController
  before_action :find_url, only: [:show]

  def index
    @url = ShortenedUrl.new
  end

  def show
    if (@url.created_at..@url.expiry_date).include?(DateTime.now)
     @url.increment!(:clicks_count)
     analytics = @url.shortened_url_analytics.new
     analytics.ip_address = request.ip || '61.12.43.186'
     analytics.country = request.location.country || 'India'
     analytics.save
     redirect_to @url.sanitize_url
    else
     render :file => 'public/404.html', :status => :not_found, :layout => false
    end
  end

  def create
    @url = ShortenedUrl.new
    @url.original_url = params[:shortened_url][:original_url]
    @url.sanitize
    respond_to do |format|
      if @url.save
        host = request.host_with_port
        @short_url = 'http://' + host + '/' + @url.short_url
        format.js
        format.json { render json: @url, status: :created, location: @url }
      else
        format.js { render action: "index" }
        format.json { render json: @url.errors, status: :unprocessable_entity }
      end
    end
  end

  def stats
    @urls = ShortenedUrl.all
  end

  private
  def find_url
    @url = ShortenedUrl.find_by_short_url(params[:short_url])
  end

end
