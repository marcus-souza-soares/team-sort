class CreateSessionPlayers < ActiveRecord::Migration[8.0]
  def change
    create_table :session_players do |t|
      t.references :game_session, null: false, foreign_key: true
      t.references :player, null: false, foreign_key: true

      t.timestamps
    end
  end
end
