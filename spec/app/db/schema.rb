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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120110153027) do

  create_table "articles", :force => true do |t|
    t.string   "title"
    t.text     "body"
    t.text     "extra"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "extend_at_anies", :force => true do |t|
    t.integer "extend_at_column_id"
    t.string  "column"
    t.text    "value"
  end

  create_table "extend_at_binaries", :force => true do |t|
    t.integer "extend_at_column_id"
    t.string  "column"
    t.binary  "value"
  end

  create_table "extend_at_booleans", :force => true do |t|
    t.integer "extend_at_column_id"
    t.string  "column"
    t.boolean "value"
  end

  create_table "extend_at_columns", :force => true do |t|
    t.integer "extend_at_id"
    t.integer "column_id"
    t.string  "column_type"
  end

  create_table "extend_at_dates", :force => true do |t|
    t.integer "extend_at_column_id"
    t.string  "column"
    t.date    "value"
  end

  create_table "extend_at_datetimes", :force => true do |t|
    t.integer  "extend_at_column_id"
    t.string   "column"
    t.datetime "value"
  end

  create_table "extend_at_decimals", :force => true do |t|
    t.integer "extend_at_column_id"
    t.string  "column"
    t.decimal "value"
  end

  create_table "extend_at_floats", :force => true do |t|
    t.integer "extend_at_column_id"
    t.string  "column"
    t.float   "value"
  end

  create_table "extend_at_integers", :force => true do |t|
    t.integer "extend_at_column_id"
    t.string  "column"
    t.integer "value"
  end

  create_table "extend_at_strings", :force => true do |t|
    t.integer "extend_at_column_id"
    t.string  "column"
    t.string  "value"
  end

  create_table "extend_at_texts", :force => true do |t|
    t.integer "extend_at_column_id"
    t.string  "column"
    t.text    "value"
  end

  create_table "extend_at_times", :force => true do |t|
    t.integer "extend_at_column_id"
    t.string  "column"
    t.time    "value"
  end

  create_table "extend_at_timestamps", :force => true do |t|
    t.integer  "extend_at_column_id"
    t.string   "column"
    t.datetime "value"
  end

  create_table "extend_ats", :force => true do |t|
    t.integer "model_id"
    t.string  "model_type"
  end

  create_table "users", :force => true do |t|
    t.string   "name"
    t.text     "private_info"
    t.text     "public_info"
    t.text     "configuration"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
