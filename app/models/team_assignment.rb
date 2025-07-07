class TeamAssignment < ApplicationRecord
  belongs_to :player
  belongs_to :team
  belongs_to :game_session

  validates :player_id, uniqueness: { scope: [:team_id, :game_session_id], message: "já está atribuído a este time nesta sessão" }

  validate :player_not_in_multiple_teams_same_session

  private

  def player_not_in_multiple_teams_same_session
    existing_assignment = TeamAssignment.where(
      player: player,
      game_session: game_session
    ).where.not(id: id).first

    if existing_assignment
      errors.add(:player, "já está em outro time nesta sessão")
    end
  end
end
