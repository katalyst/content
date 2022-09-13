# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2022_09_13_020047) do
  create_table "katalyst_content_items", force: :cascade do |t|
    t.string "type"
    t.string "container_type"
    t.integer "container_id"
    t.string "heading", null: false
    t.boolean "show_heading", default: true, null: false
    t.string "background", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["container_type", "container_id"], name: "index_katalyst_content_items_on_container"
  end

  create_table "page_versions", force: :cascade do |t|
    t.integer "parent_id", null: false
    t.json "nodes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["parent_id"], name: "index_page_versions_on_parent_id"
  end

  create_table "pages", force: :cascade do |t|
    t.string "title", null: false
    t.string "slug", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "published_version_id"
    t.integer "draft_version_id"
    t.index ["draft_version_id"], name: "index_pages_on_draft_version_id"
    t.index ["published_version_id"], name: "index_pages_on_published_version_id"
    t.index ["slug"], name: "index_pages_on_slug", unique: true
  end

  add_foreign_key "page_versions", "pages", column: "parent_id"
  add_foreign_key "pages", "page_versions", column: "draft_version_id"
  add_foreign_key "pages", "page_versions", column: "published_version_id"
end
