# frozen_string_literal: true

require_relative "lib/katalyst/content/version"

Gem::Specification.new do |spec|
  spec.name    = "katalyst-content"
  spec.version = Katalyst::Content::VERSION
  spec.authors = ["Katalyst Interactive"]
  spec.email   = ["developers@katalyst.com.au"]

  spec.summary = "Rich content page builder and editor"
  spec.homepage = "https://github.com/katalyst/content"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0"

  spec.files = Dir["{app,config,db,lib}/**/*", "spec/factories/**/*", "LICENSE.txt", "README.md"]
  spec.require_paths = ["lib"]
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.add_dependency "active_storage_validations"
end
