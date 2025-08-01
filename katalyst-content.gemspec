# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name    = "katalyst-content"
  spec.version = "3.0.0.beta.2"
  spec.authors = ["Katalyst Interactive"]
  spec.email   = ["developers@katalyst.com.au"]

  spec.summary = "Rich content page builder and editor"
  spec.homepage = "https://github.com/katalyst/content"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2"

  spec.files = Dir["{app,config,db,lib/katalyst}/**/*", "spec/factories/**/*", "LICENSE.txt", "README.md"]
  spec.require_paths = ["lib"]
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.add_dependency "activerecord"
  spec.add_dependency "active_storage_validations"
  spec.add_dependency "katalyst-govuk-formbuilder"
  spec.add_dependency "katalyst-html-attributes"
  spec.add_dependency "view_component"
end
