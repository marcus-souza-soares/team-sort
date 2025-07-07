class Player < ApplicationRecord
  has_many :team_assignments, dependent: :destroy
  has_many :teams, through: :team_assignments
  has_many :game_sessions, through: :team_assignments

  has_many :session_players, dependent: :destroy
  has_many :participating_sessions, through: :session_players, source: :game_session

  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :status, inclusion: { in: [true, false] }

  scope :active, -> { where(status: true) }
  scope :inactive, -> { where(status: false) }

  def full_name
    name.capitalize
  end

  def status_text
    status ? "Ativo" : "Inativo"
  end

  def participating_in_session?(session)
    participating_sessions.include?(session)
  end
end
