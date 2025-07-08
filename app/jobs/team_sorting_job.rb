class TeamSortingJob < ApplicationJob
  queue_as :default

  def perform(game_session_id, players_per_team = 5)
    game_session = GameSession.find(game_session_id)

    Rails.logger.info "🔄 Iniciando sorteio de times para sessão #{game_session.id} (#{game_session.date.strftime('%d/%m/%Y')})"

    begin
      # Verificar se a sessão pode ser iniciada
      unless game_session.can_start?(players_per_team)
        Rails.logger.error "❌ Sessão #{game_session.id} não pode ser iniciada - jogadores insuficientes"
        return false
      end

      # Limpar atribuições existentes
      game_session.team_assignments.destroy_all

      # Obter jogadores ativos da sessão
      players = game_session.session_participants.active.to_a

      if players.empty?
        Rails.logger.error "❌ Nenhum jogador ativo encontrado para a sessão #{game_session.id}"
        return false
      end

      # Calcular número de times possíveis
      total_teams = (players.count / players_per_team).floor

      if total_teams < 2
        Rails.logger.error "❌ Jogadores insuficientes para formar times (mínimo: #{players_per_team * 2})"
        return false
      end

      # Embaralhar jogadores
      shuffled_players = players.shuffle

      # Criar times
      teams = []
      total_teams.times do |i|
        team = Team.create!(name: "Time #{('A'.ord + i).chr}")
        teams << team
        Rails.logger.info "🏆 Time criado: #{team.name}"
      end

      # Distribuir jogadores pelos times
      shuffled_players.each_with_index do |player, index|
        team_index = index % total_teams
        team = teams[team_index]

        TeamAssignment.create!(
          player: player,
          team: team,
          game_session: game_session
        )

        Rails.logger.info "👤 #{player.name} → #{team.name}"
      end

      # Atualizar status da sessão
      game_session.update!(status: 'in_progress')

      Rails.logger.info "✅ Sorteio concluído! #{players.count} jogadores distribuídos em #{total_teams} times"

      # Enfileirar job de notificação
      TeamNotificationJob.perform_later(game_session_id)

      true

    rescue => e
      Rails.logger.error "❌ Erro no sorteio de times: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      false
    end
  end
end
