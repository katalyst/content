Rails.application.routes.draw do
  mount Katalyst::Content::Engine, at: "content"

  resources :home, only: [:index, :show]

  root to: "home#index"
end
