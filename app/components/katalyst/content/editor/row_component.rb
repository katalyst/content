# frozen_string_literal: true

module Katalyst
  module Content
    module Editor
      class RowComponent < BaseComponent
        def default_html_attributes
          { data: { controller: ITEM_CONTROLLER } }
        end
      end
    end
  end
end
