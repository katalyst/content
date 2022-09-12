Rails.application.routes.draw do
  mount Katalyst::Content::Engine, at: "content"

  resources :home, only: [:index, :show]
  resources :pages

  root to: "home#index"
end
