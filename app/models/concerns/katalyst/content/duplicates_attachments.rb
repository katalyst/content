# frozen_string_literal: true

module Katalyst
  module Content
    # Copies ActiveStorage attachments when a record is duplicated, e.g. for
    # copy-on-write. Pending changes on the source are carried over: new
    # uploads are copied to the duplicate, while attachments that are being
    # removed (either by assigning "" as govuk_attachment_field does, or via
    # nested attributes with _destroy) are dropped from the duplicate.
    module DuplicatesAttachments
      extend ActiveSupport::Concern

      def initialize_dup(source)
        super

        self.class.reflect_on_all_attachments.each do |reflection|
          DUPLICATORS.fetch(reflection.macro).new(reflection.name).apply(source, self)
        end
      end

      # Duplicates a has_one_attached attachment from source to target.
      # Public API: can be used directly for models that want to duplicate a
      # specific attachment without including the concern, e.g.
      #   DuplicatesAttachments::DupOne.new(:image).apply(source, self)
      class DupOne
        attr_reader :name

        def initialize(name)
          @name = name.to_s
        end

        def apply(source, target)
          current = source.public_send(name)
          change  = source.attachment_changes[name]

          # if attachment has changed, duplicate the change, otherwise attach the existing blob
          if change.is_a?(ActiveStorage::Attached::Changes::CreateOne)
            target.public_send("#{name}=", change.attachable)
          elsif change.is_a?(ActiveStorage::Attached::Changes::DeleteOne) ||
              current.attachment&.marked_for_destruction?
            # no-op, drop the attachment, if any
          elsif current.attached?
            target.public_send("#{name}=", current.blob)
          end
        end
      end

      # Duplicates has_many_attached attachments from source to target.
      # Public API: can be used directly for models that want to duplicate a
      # specific attachment without including the concern, e.g.
      #   DuplicatesAttachments::DupMany.new(:slides).apply(source, self)
      class DupMany
        attr_reader :name

        def initialize(name)
          @name = name.to_s
        end

        def apply(source, target)
          current = source.public_send(name)
          change  = source.attachment_changes[name]

          # if attachments have changed, duplicate the change, otherwise attach the existing blobs
          if change.is_a?(ActiveStorage::Attached::Changes::CreateMany)
            target.public_send("#{name}=", change.attachables)
          elsif change.is_a?(ActiveStorage::Attached::Changes::DeleteMany)
            # no-op, drop the attachments, if any
          elsif current.attached?
            blobs = current.attachments.reject(&:marked_for_destruction?).map(&:blob)
            target.public_send("#{name}=", blobs) if blobs.any?
          end
        end
      end

      DUPLICATORS = {
        has_one_attached:  DupOne,
        has_many_attached: DupMany,
      }.freeze
    end
  end
end
