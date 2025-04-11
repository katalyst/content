# Katalyst::Content

Katalyst Content provides tools for creating and publishing content on Rails
applications.

## Installation

Install the gem as usual

```ruby
gem "katalyst-content"
```

Mount the engine in your `routes.rb` file:

```ruby
mount Katalyst::Content::Engine, at: "content"
```

Add the Gem's migrations to your application:

```ruby
rake katalyst_content:install:migrations
```

Add the Gem's javascript and CSS to your build pipeline. This assumes that
you're using `propshaft` and `importmaps` to manage your assets.

```javascript
// app/javascript/controllers/application.js
import { application } from "controllers/application";
import content from "@katalyst/content";
application.load(content);
```

Import the editor styles as css:

```css
/** In your admin/editor */
@import url("/katalyst/content/editor.css");
/** In your frontend */
@import url("/katalyst/content/frontend.css");
```

Or, if you're using `dartsass-rails`:

```scss
// app/assets/stylesheets/admin.scss
@use "katalyst/content/editor";
// app/assets/stylesheets/application.scss
@use "katalyst/content/frontend";
```

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

Create a controller for editing content. This example assumes you're rendering the editor on the 'show' route of an
admin controller.

```ruby
class Admin::PagesController < Admin::BaseController
  before_action :set_page, only: %i[show update]
  
  def show; end

  def update
    @page.attributes = page_params

    unless @page.valid?
      return respond_to do |format|
        format.turbo_stream { render @editor.errors, status: :unprocessable_entity }
      end
    end

    case params[:commit]
    when "publish"
      @page.save!
      @page.publish!
    when "save"
      @page.save!
    when "revert"
      @page.revert!
    end

    redirect_to [:admin, @page], status: :see_other
  end
  
  private
  
  def set_page
    @page = Page.find(params[:id])
    @editor = Katalyst::Content::EditorComponent.new(container: @page)
  end

  def page_params
    params.require(:page).permit(items_attributes: %i[id index depth])
  end
end
```

And the view:

```erb
<%# app/views/admin/pages/show.html.erb %>
<%= render @editor.status_bar %>
<%= render @editor %>
```

### New items dialog customisation

The new items dialog can be customised by providing content to the ViewComponent slot:

```erb
<%# app/views/admin/pages/show.html.erb %>
<%= render @editor.status_bar %>
<%= render @editor do |editor_component| %>
  <% editor_component.with_new_items do |component| %>
    <h3>Layouts</h3>
    <ul role="list" class="items-list">
      <%= component.item(:section) %>
      <%= component.item(:group) %>
      <%= component.item(:column) %>
      <%= component.item(:aside) %>
    </ul>
    <h3>Content</h3>
    <ul role="list" class="items-list">
      <%= component.item(:content) %>
      <%= component.item(:figure) %>
      <%= component.item(:table) %>
    </ul>
  <% end %>
<% end %>

```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake` to run the tests.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the
version number and run `bundle exec rake release`, which will create a git tag for the version, push git commits and
the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/katalyst/content.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
