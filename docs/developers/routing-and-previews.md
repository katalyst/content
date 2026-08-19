---
layout: default
title: Routing and previews
parent: Developers
nav_order: 4
---

# Routing and previews

Visitors see the published version of a container, but editors need to see
draft changes before publishing them. The convention is a pair of public
routes for each container model: `show` renders the published version, and
`preview` renders the draft.

## Status bar links

The editor's status bar links to the container's public page — the published
version when the container is published, and the draft preview when it isn't.
Links are generated with `url_for(container)`, with `/preview` appended for
the draft link. This means the container model needs a resolvable public
route (`page_path` for a `Page`) with a `preview` member route alongside it —
without one, rendering the editor raises a routing error such as
`undefined method 'page_path'`.

## Routes and controller

```ruby
# config/routes.rb
resources :pages, only: :show do
  get :preview, on: :member
end
```

```ruby
class PagesController < ApplicationController
  helper Katalyst::Content::FrontendHelper

  before_action :set_page
  before_action :set_version

  attr_reader :page, :version

  def show
    raise ActiveRecord::RecordNotFound unless page.published?

    render locals: { page:, version: }
  end

  def preview
    raise ActiveRecord::RecordNotFound unless admin_signed_in?

    return redirect_to(action: :show, status: :see_other) if page.state == "published"

    render :show, locals: { page:, version: }
  end

  private

  def set_page
    @page = Page.find(params[:id])
  end

  def set_version
    @version = action_name == "preview" ? page.draft_version : page.published_version
  end
end
```

```erb
<%# app/views/pages/show.html.erb %>
<%# locals: (page:, version:) %>
<%= render_content(version) %>
```

Details worth noting:

* `preview` redirects to `show` when there are no draft changes, keeping the
  published URL canonical.
* Previews expose unpublished content, so `preview` raises
  `ActiveRecord::RecordNotFound` unless an editor is signed in — a 404,
  rather than a redirect, so drafts don't reveal their existence.
  `admin_signed_in?` is provided by your application; in Koi applications,
  include `Koi::Controller::HasAdminUsers`.

## Root-level slugs

CMS pages are often expected at `/about-us` rather than `/pages/about-us`.
Combine a routing constraint with a resolver to serve container slugs at the
root without claiming paths that belong to other routes:

```ruby
# config/routes.rb
constraints PageRequest::Constraints do
  resources :pages, path: "", only: %i[show], param: :slug, constraints: { format: :html } do
    get :preview, on: :member
  end
end

resolve("Page") { |page, options = {}| [:page, { slug: page.slug, **options }] }
```

* `path: ""` removes the `/pages` prefix while keeping `resources` wiring and
  URL helpers.
* `constraints: { format: :html }` leaves other formats free for other
  controllers.
* `resolve("Page")` makes `url_for(page)` — and therefore the status bar
  links — generate the friendly slug rather than `/pages/:id`.

The constraint decides whether a request *routes*, nothing more: a published
page matches for everyone, and any existing page matches for `preview`.
Returning `false` lets the router fall through to later routes, so unknown
slugs 404 naturally. Authorisation stays in the controller — constraints run
during route matching, before controller filters, so session-derived state
(such as Koi's `Current`) hasn't been established yet, and routing outcomes
shouldn't vary by who is asking.

A concern keeps the controller lean and shares the slug lookup between the
constraint and the controller — the matched page is cached on the request so
the controller doesn't repeat the query:

```ruby
# app/controllers/concerns/page_request.rb
module PageRequest
  PAGE_HEADER = "katalyst.matched.page"

  def page
    request.get_header(PAGE_HEADER)
  end

  def page=(page)
    request.set_header(PAGE_HEADER, page)
  end

  def slug
    request.params[:slug]
  end

  class Constraints
    include PageRequest

    def self.matches?(request) = new(request).match?

    attr_reader :request

    def initialize(request)
      @request = request
    end

    # Implement constraints API. Routing only — no authorisation.
    def match?
      if request.get? && slug.present? && (self.page = Page.find_by(slug:)).present?
        page.published? || request.params[:action] == "preview"
      end
    end
  end
end
```

```ruby
class PagesController < ApplicationController
  include PageRequest

  helper Katalyst::Content::FrontendHelper

  before_action :set_version

  attr_reader :version

  def show
    render locals: { page:, version: }
  end

  def preview
    raise ActiveRecord::RecordNotFound unless admin_signed_in?

    return redirect_to(action: :show, status: :see_other) if page.state == "published"

    render :show, locals: { page:, version: }
  end

  private

  def set_version
    @version = action_name == "preview" ? page.draft_version : page.published_version
  end
end
```

The `page` reader comes from the concern, and the view is unchanged from the
basic example above — only the routing and lookup differ.

When using this pattern:

* Validate and index slug uniqueness — collisions produce confusing
  fallbacks.
* Keep explicit static routes above the constraint block; the constraint
  claims any matching slug, so routes defined after it may never run.
* Only one module can own arbitrary root slugs. If several models need
  root-level URLs, introduce a prefix or a dispatcher that inspects the slug
  instead of stacking constraints.
