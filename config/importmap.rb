# frozen_string_literal: true

pin "trix"
pin "@rails/actiontext", to: "actiontext.js"

pin_all_from Katalyst::Content::Engine.root.join("app/assets/javascripts"),
             # preload in tests so that we don't start clicking before controllers load
             preload: Rails.env.test?
