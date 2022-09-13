# frozen_string_literal: true

module Katalyst
  module Content
    # STI base class for content items
    class Item < ApplicationRecord
      belongs_to :container, polymorphic: true

      validates :heading, presence: true
      validates :background, presence: true, inclusion: { in: Content.config.backgrounds }
    end
  end
end
