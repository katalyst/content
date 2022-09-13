# frozen_string_literal: true

class Page < ApplicationRecord
  include Katalyst::Content::Container

  validates_presence_of :title, :slug
  validates_uniqueness_of :slug

  before_validation :initialize_slug

  private

  def initialize_slug
    self.slug = title&.parameterize if slug.blank?
  end

  class Version < ApplicationRecord
    include Katalyst::Content::Version
  end
end
