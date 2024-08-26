# frozen_string_literal: true

module Katalyst
  module Content
    class Aside < Layout
      style_attributes do
        attribute :reverse, :boolean, default: false
      end

      def self.permitted_params
        super + %i[reverse]
      end
    end
  end
end
