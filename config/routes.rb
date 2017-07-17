Rails.application.routes.draw do
  resources :testapps
  # resources :search
  get 'search/search'

  get 'search/view'
  post 'search/view'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: "search#search"
end
