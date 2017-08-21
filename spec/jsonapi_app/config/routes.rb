Rails.application.routes.draw do
  jsonapi_resources :authors
  jsonapi_resources :posts
  jsonapi_resources :comments

  resources :database_cleanings, only: :create
end
