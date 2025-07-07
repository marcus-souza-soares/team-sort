json.extract! game_session, :id, :date, :players_per_team, :status, :created_at, :updated_at
json.url game_session_url(game_session, format: :json)
