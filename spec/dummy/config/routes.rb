Rails.application.routes.draw do
  mount Katalyst::Content::Engine, at: "content"

  root to: "home#index"
end
