# frozen_string_literal: true

# Run using bin/ci

CI.run do
  step "Style: RuboCop", "bundle exec rake lint"
  step "Style: ERB", "bundle exec rake erb_lint"
  step "Style: Prettier", "bundle exec rake prettier"
  step "Assets: Build", "bundle exec rake build"
  step "Tests: RSpec", "bundle exec rake spec"
  step "Security: Brakeman", "bundle exec rake security"
end
