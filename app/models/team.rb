class Team < ApplicationRecord
  has_many :team_assignments, dependent: :destroy
  has_many :players, through: :team_assignments
  has_many :game_sessions, through: :team_assignments

  validates :name, presence: true

  def player_count
    players.count
  end

  def to_s
    name
  end
end
