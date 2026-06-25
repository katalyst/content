# frozen_string_literal: true

Katalyst::Content::Engine.routes.draw do
  resources :items
  resources :tables, only: %i[create update]
end
