# frozen_string_literal: true

module Katalyst
  module Content
    # Copies ActionText rich text attributes when a record is duplicated,
    # e.g. for copy-on-write. Unsaved changes on the source are carried over
    # to the duplicate.
    module DuplicatesRichText
      extend ActiveSupport::Concern

      def initialize_dup(source)
        super

        self.class.rich_text_association_names.each do |association|
          DupRichText.new(association.to_s.delete_prefix("rich_text_")).apply(source, self)
        end
      end

      # Duplicates a has_rich_text attribute from source to target.
      # Public API: can be used directly for models that want to duplicate a
      # specific rich text attribute without including the concern, e.g.
      #   DuplicatesRichText::DupRichText.new(:subtitle).apply(source, self)
      class DupRichText
        attr_reader :name

        def initialize(name)
          @name = name.to_s
        end

        def apply(source, target)
          rich_text = source.public_send("rich_text_#{name}")

          # copy via body assignment so that custom attribute writers
          # (e.g. Table#content=) are not re-run on the duplicate
          target.public_send(name).body = rich_text.body if rich_text
        end
      end
    end
  end
end
