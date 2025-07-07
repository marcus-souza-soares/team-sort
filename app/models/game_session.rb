class GameSession < ApplicationRecord
  has_many :team_assignments, dependent: :destroy
  has_many :players, through: :team_assignments
  has_many :teams, through: :team_assignments

  has_many :session_players, dependent: :destroy
  has_many :session_participants, through: :session_players, source: :player

  validates :date, presence: true
  validates :status, presence: true, inclusion: { in: %w[scheduled in_progress completed cancelled] }

  scope :scheduled, -> { where(status: 'scheduled') }
  scope :in_progress, -> { where(status: 'in_progress') }
  scope :completed, -> { where(status: 'completed') }
  scope :cancelled, -> { where(status: 'cancelled') }

  def status_text
    case status
    when 'scheduled'
      'Agendada'
    when 'in_progress'
      'Em Andamento'
    when 'completed'
      'Finalizada'
    when 'cancelled'
      'Cancelada'
    else
      status
    end
  end

  def total_players
    session_participants.count
  end

  def total_teams
    teams.distinct.count
  end

  def can_start?(players_per_team = 5)
    status == 'scheduled' && total_players >= players_per_team
  end

  def can_complete?
    status == 'in_progress'
  end

  def add_player(player)
    session_players.create(player: player) unless session_participants.include?(player)
  end

  def remove_player(player)
    session_players.find_by(player: player)&.destroy
  end

  def has_player?(player)
    session_participants.include?(player)
  end

  def possible_teams(players_per_team)
    return 0 if players_per_team <= 0
    (total_players / players_per_team).floor
  end
end
