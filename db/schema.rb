# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20151101063919) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "fills", force: :cascade do |t|
    t.integer  "price"
    t.integer  "quantity"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "buy_order_id"
    t.integer  "sell_order_id"
  end

  add_index "fills", ["buy_order_id"], name: "index_fills_on_buy_order_id", using: :btree
  add_index "fills", ["sell_order_id"], name: "index_fills_on_sell_order_id", using: :btree

  create_table "orders", force: :cascade do |t|
    t.integer  "stock_id"
    t.text     "type"
    t.integer  "quantity"
    t.integer  "price"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "user_id"
    t.datetime "fulfilled_at"
  end

  add_index "orders", ["stock_id"], name: "index_orders_on_stock_id", using: :btree
  add_index "orders", ["user_id"], name: "index_orders_on_user_id", using: :btree

  create_table "stocks", force: :cascade do |t|
    t.text     "name"
    t.text     "symbol"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "stocks", ["name"], name: "index_stocks_on_name", unique: true, using: :btree
  add_index "stocks", ["symbol"], name: "index_stocks_on_symbol", unique: true, using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.integer  "money"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
