class RemovePlayersPerTeamFromGameSessions < ActiveRecord::Migration[8.0]
  def change
    remove_column :game_sessions, :players_per_team, :integer
  end
end
