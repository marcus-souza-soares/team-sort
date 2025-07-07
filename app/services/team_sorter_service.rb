class TeamSorterService
  attr_reader :game_session, :players, :players_per_team

  def initialize(game_session, players_per_team = 5)
    @game_session = game_session
    @players = game_session.session_participants.active.to_a
    @players_per_team = players_per_team
  end

  def sort_teams
    return { success: false, message: "Não há jogadores suficientes" } if players.empty?
    return { success: false, message: "Número de jogadores insuficiente para formar times" } if players.count < players_per_team

    # Limpar atribuições anteriores desta sessão
    game_session.team_assignments.destroy_all

    # Calcular número de times necessários
    total_players = players.count
    number_of_teams = (total_players / players_per_team).floor
    remaining_players = total_players % players_per_team

    # Embaralhar jogadores
    shuffled_players = players.shuffle

    # Criar times
    teams = []
    player_index = 0

    # Criar times completos
    number_of_teams.times do |i|
      team = Team.create!(name: "Time #{i + 1}")
      teams << team

      # Adicionar jogadores ao time
      players_per_team.times do
        break if player_index >= shuffled_players.count
        player = shuffled_players[player_index]
        TeamAssignment.create!(
          player: player,
          team: team,
          game_session: game_session
        )
        player_index += 1
      end
    end

    # Criar time adicional com jogadores restantes (se houver)
    if remaining_players > 0
      team = Team.create!(name: "Time #{teams.count + 1}")
      teams << team

      remaining_players.times do
        break if player_index >= shuffled_players.count
        player = shuffled_players[player_index]
        TeamAssignment.create!(
          player: player,
          team: team,
          game_session: game_session
        )
        player_index += 1
      end
    end

    # Atualizar status da sessão
    game_session.update!(status: 'in_progress')

    {
      success: true,
      message: "Times sorteados com sucesso! #{teams.count} times criados.",
      teams: teams,
      total_players: total_players,
      players_per_team: players_per_team,
      complete_teams: number_of_teams,
      teams_with_remaining: remaining_players > 0 ? 1 : 0
    }
  end

  def self.sort_teams_for_session(game_session, players_per_team = 5)
    new(game_session, players_per_team).sort_teams
  end
end
