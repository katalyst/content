Rails.application.routes.draw do
  mount Katalyst::Content::Engine, at: "content"

  resources :home, only: [:index, :show]

  namespace :admin do
    resources :pages
  end

  resources :pages, param: :slug, only: :show, path: ""

  root to: "home#index"
end
