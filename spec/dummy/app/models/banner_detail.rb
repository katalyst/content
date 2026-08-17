# frozen_string_literal: true

# Owned detail record for Banner, extending the STI model with a has_one
# association. Not distributed with the gem; exists to test copy-on-write
# duplication of owned associations.
class BannerDetail < ApplicationRecord
  belongs_to :detailable, polymorphic: true
end
