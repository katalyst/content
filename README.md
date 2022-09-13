# Katalyst::Content

Katalyst Content provides tools for creating and publishing content on Rails
applications.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'katalyst-content'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install katalyst-content

## Usage

Content can be added to multiple models in your application. These examples
assume a `Page` model.

Assuming your model already exists, create a table for versions and add
published and draft version columns to your model. For example, if you have a
pages model:

```ruby
class CreatePageVersions < ActiveRecord::Migration[7.0]
  def change
    create_table :page_versions do |t|
      t.references :parent, foreign_key: { to_table: :pages }, null: false
      t.json :nodes

      t.timestamps
    end

    change_table :pages do |t|
      t.references :published_version, foreign_key: { to_table: :page_versions }
      t.references :draft_version, foreign_key: { to_table: :page_versions }
    end
  end
end
```

Next, include the `Katalyst::Content` concerns into your model, and add a nested
model for storing content version information:

```ruby
class Page < ApplicationRecord
  include Katalyst::Content::Container

  class Version < ApplicationRecord
    include Katalyst::Content::Version
  end
end
```

You may also want to configure your factory to add container information to
items:

```ruby
FactoryBot.define do
  factory :page do
    title { Faker::Beer.unique.name }
    slug { title.parameterize }

    after(:build) do |page, _context|
      page.items.each { |item| item.container = page }
    end

    after(:create) do |page, _context|
      page.items_attributes = page.items.map.with_index { |item, index| { id: item.id, index: index, depth: 0 } }
      page.publish!
    end
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake` to run the tests.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/katalyst/content.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
