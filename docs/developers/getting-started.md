---
layout: default
title: Getting started
parent: Developers
nav_order: 1
---

# Getting started

Add this line to your application's Gemfile:

```ruby
gem "katalyst-content"
```

Mount the engine in your `routes.rb` file:

```ruby
mount Katalyst::Content::Engine, at: "content"
```

Add the gem's migrations to your application:

```shell
rake katalyst_content:install:migrations
```

Add the gem's javascript and CSS to your build pipeline. This assumes that
you're using `propshaft` and `importmaps` to manage your assets.

```javascript
// app/javascript/controllers/application.js
import { application } from "controllers/application";
import content from "@katalyst/content";
application.load(content);
```

Import the editor styles as CSS:

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

## Adding content to a model

Content can be added to multiple models in your application. These examples
assume a `Page` model.

Create a table for versions and add published and draft version columns to
your model:

```ruby
class CreatePageVersions < ActiveRecord::Migration[8.0]
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

Next, include the `Katalyst::Content` concerns into your model, and add a
nested model for storing content version information:

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

## Rendering the editor

Create a controller for editing content. This example assumes you're rendering
the editor on the `show` route of an admin controller.

```ruby
class Admin::PagesController < Admin::BaseController
  before_action :set_page, only: %i[show update]

  attr_reader :page, :editor

  def show
    render locals: { editor: }
  end

  def update
    page.attributes = page_params

    unless page.valid?
      return respond_to do |format|
        format.turbo_stream { render editor.errors, status: :unprocessable_content }
      end
    end

    case params[:commit]
    when "publish"
      page.save!
      page.publish!
    when "save"
      page.save!
    when "revert"
      page.revert!
    end

    redirect_to [:admin, page], status: :see_other
  end

  private

  def set_page
    @page = Page.find(params[:id])
    @editor = Katalyst::Content::EditorComponent.new(container: page)
  end

  def page_params
    params.require(:page).permit(items_attributes: %i[id index depth])
  end
end
```

And the view:

```erb
<%# app/views/admin/pages/show.html.erb %>
<%# locals: (editor:) %>
<%= render editor.status_bar %>
<%= render editor %>
```

## Rendering content in your frontend

Include `Katalyst::Content::FrontendHelper` and render the published version:

```erb
<%# app/views/pages/show.html.erb %>
<%# locals: (page:, version:) %>
<%= render_content(version) %>
```

The editor's status bar links to the container's public page and a draft
preview — see [routing and previews](routing-and-previews) for the routes
this expects.

## Customising the new items dialog

The new items dialog can be customised by providing content to the
ViewComponent slot:

```erb
<%# app/views/admin/pages/show.html.erb %>
<%# locals: (editor:) %>
<%= render editor.status_bar %>
<%= render editor do |editor_component| %>
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
