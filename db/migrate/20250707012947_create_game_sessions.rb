class CreateGameSessions < ActiveRecord::Migration[8.0]
  def change
    create_table :game_sessions do |t|
      t.datetime :date
      t.integer :players_per_team
      t.string :status

      t.timestamps
    end
  end
end
