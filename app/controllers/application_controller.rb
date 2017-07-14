class ApplicationController < ActionController::API
  # Prevent CSRF attacks by raising exception
  # * not necessary b/c inherits from ::API
  # protect_from_forgery with: :null_session
end
