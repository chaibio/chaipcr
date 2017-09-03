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

ActiveRecord::Schema.define(version: 20170816215759) do

  create_table "amplification_curves", force: true do |t|
    t.integer "experiment_id"
    t.integer "stage_id"
    t.integer "well_num"
    t.decimal "ct",                      precision: 9, scale: 6
    t.integer "channel",       limit: 1,                         default: 1, null: false
  end

  add_index "amplification_curves", ["experiment_id", "stage_id", "well_num", "channel"], name: "index_amplification_curves_by_exp_chan_stage_well_channel", unique: true, using: :btree

  create_table "amplification_data", force: true do |t|
    t.integer "experiment_id"
    t.integer "stage_id"
    t.integer "well_num",                                                       comment: "0-15"
    t.integer "cycle_num",                                                      comment: "0-15"
    t.integer "background_subtracted_value"
    t.integer "baseline_subtracted_value"
    t.integer "channel",                     limit: 1, default: 1, null: false
    t.integer "sub_id"
    t.string  "sub_type"
  end

  add_index "amplification_data", ["experiment_id", "stage_id", "cycle_num", "well_num", "channel"], name: "index_amplification_data_by_exp_chan_stage_cycle_well_channel", unique: true, using: :btree

  create_table "amplification_options", force: true do |t|
    t.integer "experiment_definition_id"
    t.string  "cq_method"
    t.integer "min_fluorescence"
    t.integer "min_reliable_cycle"
    t.integer "min_d1"
    t.integer "min_d2"
    t.integer "baseline_cycle_min"
    t.integer "baseline_cycle_max"
  end

  create_table "cached_analyze_data", force: true do |t|
    t.integer "experiment_id"
    t.text    "analyze_result", limit: 16777215
  end

  add_index "cached_analyze_data", ["experiment_id"], name: "index_cached_analyze_data_on_experiment_id", unique: true, using: :btree

  create_table "cached_melt_curve_data", force: true do |t|
    t.integer "experiment_id"
    t.integer "stage_id"
    t.integer "channel"
    t.integer "well_num",                              comment: "1-16"
    t.text    "temperature_text",     limit: 16777215
    t.text    "normalized_data_text", limit: 16777215
    t.text    "derivative_data_text", limit: 16777215
    t.text    "tm_text"
    t.text    "area_text"
    t.integer "ramp_id"
  end

  add_index "cached_melt_curve_data", ["experiment_id", "stage_id", "channel", "well_num"], name: "index_meltcurvedata_by_exp_stage_chan_well", unique: true, using: :btree

  create_table "experiment_definitions", force: true do |t|
    t.string "guid"
    t.string "experiment_type", null: false
  end

  add_index "experiment_definitions", ["guid"], name: "index_experiment_definitions_on_guid", using: :btree

  create_table "experiments", force: true do |t|
    t.datetime "started_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "completed_at"
    t.string   "completion_status"
    t.string   "completion_message"
    t.integer  "experiment_definition_id"
    t.integer  "calibration_id"
    t.boolean  "time_valid",                                       default: true
    t.string   "analyze_status"
    t.decimal  "cached_temperature",       precision: 7, scale: 4
    t.integer  "power_cycles"
    t.string   "name"
  end

  create_table "fluorescence_data", id: false, force: true do |t|
    t.integer "step_id"
    t.integer "fluorescence_value"
    t.integer "well_num",                                              comment: "0-15"
    t.integer "cycle_num"
    t.integer "experiment_id"
    t.integer "ramp_id"
    t.integer "channel",            limit: 1, default: 1, null: false
    t.integer "baseline_value",               default: 0
  end

  add_index "fluorescence_data", ["experiment_id", "channel", "ramp_id", "cycle_num", "well_num"], name: "index_fluorescence_data_by_exp_chan_ramp_cycle_well", unique: true, using: :btree
  add_index "fluorescence_data", ["experiment_id", "channel", "step_id", "cycle_num", "well_num"], name: "index_fluorescence_data_by_exp_chan_step_cycle_well", unique: true, using: :btree

  create_table "fluorescence_debug_data", id: false, force: true do |t|
    t.integer "step_id"
    t.integer "well_num",                                           comment: "0-15"
    t.integer "cycle_num"
    t.integer "experiment_id"
    t.integer "ramp_id"
    t.integer "channel",         limit: 1, default: 1, null: false
    t.string  "optical_values"
    t.string  "baseline_values"
  end

  add_index "fluorescence_debug_data", ["experiment_id", "channel", "ramp_id", "cycle_num", "well_num"], name: "index_fluorescence_debug_data_by_exp_chan_ramp_cycle_well", unique: true, using: :btree
  add_index "fluorescence_debug_data", ["experiment_id", "channel", "step_id", "cycle_num", "well_num"], name: "index_fluorescence_debug_data_by_exp_chan_step_cycle_well", unique: true, using: :btree

  create_table "melt_curve_data", force: true do |t|
    t.integer "stage_id",                                                         null: false
    t.integer "well_num",                                                         null: false, comment: "0-15"
    t.decimal "temperature",                  precision: 7, scale: 4,                          comment: "degrees C"
    t.integer "fluorescence_value"
    t.integer "experiment_id"
    t.integer "channel",            limit: 1,                         default: 1, null: false
    t.integer "ramp_id"
    t.string  "optical_values"
  end

  add_index "melt_curve_data", ["experiment_id", "stage_id", "well_num", "temperature"], name: "melt_curve_data_index", using: :btree

  create_table "protocols", force: true do |t|
    t.decimal "lid_temperature",          precision: 4, scale: 1, comment: "degrees C"
    t.integer "experiment_definition_id"
  end

  create_table "ramps", force: true do |t|
    t.decimal "rate",                           precision: 11, scale: 8,                 null: false, comment: "degrees C/s, set to 100 for max"
    t.integer "next_step_id"
    t.boolean "collect_data",                                            default: false
    t.integer "excitation_intensity", limit: 3
  end

  add_index "ramps", ["next_step_id"], name: "index_ramps_on_next_step_id", unique: true, using: :btree

  create_table "settings", force: true do |t|
    t.boolean "debug",                    default: false
    t.string  "time_zone"
    t.string  "wifi_ssid"
    t.string  "wifi_password"
    t.boolean "wifi_enabled",             default: true
    t.integer "calibration_id"
    t.boolean "time_valid",               default: true
    t.string  "software_release_variant", default: "stable", null: false
    t.integer "power_cycles",             default: 0
  end

  create_table "stages", force: true do |t|
    t.string   "name"
    t.integer  "num_cycles",                             null: false
    t.integer  "order_number",           default: 0,     null: false
    t.integer  "protocol_id"
    t.string   "stage_type",                             null: false, comment: "holding, cycling, or meltcurve"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "auto_delta",             default: false
    t.integer  "auto_delta_start_cycle", default: 1
  end

  add_index "stages", ["protocol_id", "order_number"], name: "index_stages_on_protocol_id_and_order_number", unique: true, using: :btree

  create_table "steps", force: true do |t|
    t.string   "name"
    t.decimal  "temperature",                    precision: 4, scale: 1,                 null: false, comment: "degrees C"
    t.integer  "hold_time",                                                              null: false, comment: "in seconds, 0 means infinite"
    t.integer  "order_number",                                           default: 0,     null: false, comment: "the order of the step in the cycle, starting with 0, and continguous"
    t.integer  "stage_id",                                                               null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "collect_data",                                           default: false
    t.decimal  "delta_temperature",              precision: 4, scale: 2, default: 0.0
    t.integer  "delta_duration_s",                                       default: 0
    t.boolean  "pause",                                                  default: false
    t.integer  "excitation_intensity", limit: 3
  end

  add_index "steps", ["stage_id", "order_number"], name: "index_steps_on_stage_id_and_order_number", unique: true, using: :btree

  create_table "temperature_debug_logs", id: false, force: true do |t|
    t.integer "experiment_id"
    t.integer "elapsed_time",                                    comment: "in milliseconds"
    t.decimal "lid_drive",               precision: 5, scale: 4
    t.decimal "heat_block_zone_1_drive", precision: 5, scale: 4
    t.decimal "heat_block_zone_2_drive", precision: 5, scale: 4
    t.decimal "heat_sink_temp",          precision: 5, scale: 2, comment: "degrees C"
    t.decimal "heat_sink_drive",         precision: 5, scale: 4
  end

  add_index "temperature_debug_logs", ["experiment_id", "elapsed_time"], name: "index_temperature_debug_logs_on_experiment_id_and_elapsed_time", unique: true, using: :btree

  create_table "temperature_logs", id: false, force: true do |t|
    t.integer "experiment_id"
    t.integer "elapsed_time",                                   comment: "in milliseconds"
    t.decimal "lid_temp",               precision: 5, scale: 2, comment: "degrees C"
    t.decimal "heat_block_zone_1_temp", precision: 5, scale: 2, comment: "degrees C"
    t.decimal "heat_block_zone_2_temp", precision: 5, scale: 2, comment: "degrees C"
    t.integer "stage_id"
    t.integer "cycle_num"
    t.integer "step_id"
    t.integer "ramp_id"
  end

  add_index "temperature_logs", ["experiment_id", "elapsed_time"], name: "index_temperature_logs_on_experiment_id_and_elapsed_time", unique: true, using: :btree

  create_table "upgrades", force: true do |t|
    t.string   "version",                           null: false
    t.string   "checksum",                          null: false
    t.datetime "release_date",                      null: false
    t.text     "brief_description"
    t.text     "full_description"
    t.string   "password"
    t.boolean  "downloaded",        default: false
  end

  create_table "user_tokens", force: true do |t|
    t.integer  "user_id"
    t.string   "access_token"
    t.datetime "expired_at"
    t.datetime "created_at"
  end

  add_index "user_tokens", ["access_token"], name: "index_user_tokens_on_access_token", unique: true, using: :btree

  create_table "users", force: true do |t|
    t.string   "email",           null: false
    t.string   "password_digest", null: false
    t.string   "role",            null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",            null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree

  create_table "wells", force: true do |t|
    t.integer "experiment_id",                  null: false
    t.integer "well_num",                       null: false
    t.string  "well_type",                      null: false, comment: "positive_control, no_template_control, standard, sample"
    t.string  "sample_name"
    t.text    "notes",         limit: 16777215
    t.string  "target1"
    t.string  "target2"
  end

end
