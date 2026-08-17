# frozen_string_literal: true

# Owned detail record for Banner, extending the STI model with a has_many
# association. Not distributed with the gem; exists to test copy-on-write
# duplication of owned associations.
class BannerNote < ApplicationRecord
  belongs_to :notable, polymorphic: true
end
