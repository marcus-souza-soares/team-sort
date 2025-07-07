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

ActiveRecord::Schema[8.0].define(version: 2025_07_07_015838) do
  create_table "game_sessions", force: :cascade do |t|
    t.datetime "date"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "players", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "phone"
    t.string "position"
    t.boolean "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "session_players", force: :cascade do |t|
    t.integer "game_session_id", null: false
    t.integer "player_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_session_id"], name: "index_session_players_on_game_session_id"
    t.index ["player_id"], name: "index_session_players_on_player_id"
  end

  create_table "team_assignments", force: :cascade do |t|
    t.integer "player_id", null: false
    t.integer "team_id", null: false
    t.integer "game_session_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_session_id"], name: "index_team_assignments_on_game_session_id"
    t.index ["player_id"], name: "index_team_assignments_on_player_id"
    t.index ["team_id"], name: "index_team_assignments_on_team_id"
  end

  create_table "teams", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "session_players", "game_sessions"
  add_foreign_key "session_players", "players"
  add_foreign_key "team_assignments", "game_sessions"
  add_foreign_key "team_assignments", "players"
  add_foreign_key "team_assignments", "teams"
end
