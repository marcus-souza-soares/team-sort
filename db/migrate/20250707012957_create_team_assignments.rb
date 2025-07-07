class CreateTeamAssignments < ActiveRecord::Migration[8.0]
  def change
    create_table :team_assignments do |t|
      t.references :player, null: false, foreign_key: true
      t.references :team, null: false, foreign_key: true
      t.references :game_session, null: false, foreign_key: true

      t.timestamps
    end
  end
end
