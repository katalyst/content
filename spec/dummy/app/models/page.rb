# frozen_string_literal: true

class Page < ApplicationRecord
  validates_presence_of :title, :slug
  validates_uniqueness_of :slug

  before_validation :initialize_slug

  private

  def initialize_slug
    self.slug = title&.parameterize if slug.blank?
  end
end
