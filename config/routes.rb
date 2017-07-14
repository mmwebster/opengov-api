Rails.application.routes.draw do
  namespace :api do
    namespace :v1, :defaults => { :format => :json } do
      # resource :web_data
      # resource :web_statuses
      jsonapi_resources :web_data
      jsonapi_resources :web_statuses
    end
  end

  # root to: "home#index" # not sure if necessary

  # namespace :api do
  #   namespace :v1, :defaults => { :format => :json } do
  #     jsonapi_resources :web_status
  #     jsonapi_resources :web_data
  #   end
  # end
end
