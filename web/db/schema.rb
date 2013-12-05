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

ActiveRecord::Schema.define(version: 20131204195402) do

  create_table "components", force: true do |t|
    t.string   "name"
    t.integer  "order_number", default: 0, null: false
    t.integer  "repeat"
    t.integer  "temperature"
    t.integer  "hold_time"
    t.integer  "parent_id"
    t.integer  "protocol_id",              null: false
    t.string   "type",                     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "protocols", force: true do |t|
    t.string   "name"
    t.datetime "run_at"
    t.integer  "master_cycle_id"
    t.boolean  "running",         default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "runs", force: true do |t|
    t.boolean  "qpcr"
    t.integer  "protocol_id"
    t.datetime "run_at"
    t.boolean  "running"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
