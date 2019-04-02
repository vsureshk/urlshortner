Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'shortened_urls#index'
  get "/stats", to: 'shortened_urls#stats'
  get "/:short_url", to: 'shortened_urls#show'
  get "shortened/:short_url", to: 'shortened_urls#shortened', as: :shortened
  post "/shortened_urls/create"
  get "/shortened_urls/fetch_original_url"
end
