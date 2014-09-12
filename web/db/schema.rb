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

ActiveRecord::Schema.define(version: 20140912200833) do

  create_table "experiments", force: true do |t|
    t.string   "name"
    t.boolean  "qpcr",              default: true
    t.datetime "started_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "completed_at"
    t.string   "completion_status"
  end

  create_table "fluorescence_data", id: false, force: true do |t|
    t.integer "step_id"
    t.integer "fluorescence_value"
    t.integer "well_num",           comment: "0-15"
    t.integer "cycle_num"
  end

  create_table "protocols", force: true do |t|
    t.decimal  "lid_temperature", precision: 4, scale: 1
    t.integer  "experiment_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ramps", force: true do |t|
    t.decimal "rate",         precision: 11, scale: 8, null: false
    t.integer "next_step_id"
  end

  create_table "settings", id: false, force: true do |t|
    t.boolean "debug", default: false
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

  create_table "temperature_debug_logs", id: false, force: true do |t|
    t.integer "experiment_id"
    t.integer "elapsed_time",                                    comment: "in milliseconds"
    t.decimal "lid_drive",               precision: 6, scale: 1
    t.decimal "heat_block_zone_1_drive", precision: 6, scale: 1
    t.decimal "heat_block_zone_2_drive", precision: 6, scale: 1
  end

  add_index "temperature_debug_logs", ["experiment_id", "elapsed_time"], name: "index_temperature_debug_logs_on_experiment_id_and_elapsed_time", unique: true

  create_table "temperature_logs", id: false, force: true do |t|
    t.integer "experiment_id"
    t.integer "elapsed_time",                                   comment: "in seconds"
    t.decimal "lid_temp",               precision: 5, scale: 2
    t.decimal "heat_block_zone_1_temp", precision: 5, scale: 2
    t.decimal "heat_block_zone_2_temp", precision: 5, scale: 2
  end

  add_index "temperature_logs", ["experiment_id", "elapsed_time"], name: "index_temperature_logs_on_experiment_id_and_elapsed_time", unique: true

  create_table "user_tokens", force: true do |t|
    t.integer  "user_id"
    t.string   "access_token"
    t.datetime "expired_at"
    t.datetime "created_at"
  end

  add_index "user_tokens", ["access_token"], name: "index_user_tokens_on_access_token", unique: true

  create_table "users", force: true do |t|
    t.string   "email",                       null: false
    t.string   "password_digest",             null: false
    t.integer  "role",            default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true

end
