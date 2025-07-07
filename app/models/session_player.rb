class SessionPlayer < ApplicationRecord
  belongs_to :game_session
  belongs_to :player

  validates :player_id, uniqueness: { scope: :game_session_id, message: "já está nesta sessão" }

  validate :player_must_be_active

  private

  def player_must_be_active
    unless player&.status?
      errors.add(:player, "deve estar ativo para participar da sessão")
    end
  end
end
