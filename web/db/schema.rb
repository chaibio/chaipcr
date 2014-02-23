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

  create_table "experiments", force: true do |t|
    t.string   "name"
    t.boolean  "qpcr",       default: true
    t.datetime "run_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "protocols", force: true do |t|
    t.decimal  "lid_temperature", precision: 4, scale: 1
    t.integer  "experiment_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ramps", force: true do |t|
    t.decimal "rate",    precision: 11, scale: 8, null: false
    t.integer "next_step_id"
  end

  create_table "stages", force: true do |t|
    t.string   "name"
    t.integer  "num_cycles",   default: 1, null: false
    t.integer  "order_number", default: 0, null: false
    t.integer  "protocol_id"
    t.string   "stage_type",               null: false, comment: "holding, cycling, or meltcurve"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "steps", force: true do |t|
    t.string   "name"
    t.decimal  "temperature",  precision: 4, scale: 1,             null: false
    t.integer  "hold_time",                                        null: false, comment: "in seconds, 0 means infinite"
    t.integer  "order_number",                         default: 0, null: false, comment: "the order of the step in the cycle, starting with 0, and continguous"
    t.integer  "stage_id",                                         null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
