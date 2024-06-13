# frozen_string_literal: true

Katalyst::Content::Engine.routes.draw do
  resources :direct_uploads, only: :create
  resources :items
  resources :tables, only: %i[create update]
end
