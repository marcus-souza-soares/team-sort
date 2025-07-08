class TeamNotificationJob < ApplicationJob
  queue_as :notifications

  def perform(game_session_id)
    game_session = GameSession.find(game_session_id)

    Rails.logger.info "📢 Iniciando envio de notificações para sessão #{game_session.id}"

    begin
      # Agrupar jogadores por time
      teams_with_players = game_session.teams.includes(:players).map do |team|
        # Usar TeamAssignment para obter jogadores do time nesta sessão específica
        players = team.players.joins(:team_assignments)
                              .where(team_assignments: { game_session: game_session })
        {
          team: team,
          players: players,
          player_count: players.count
        }
      end

      # Log das informações dos times
      teams_with_players.each do |team_info|
        team = team_info[:team]
        players = team_info[:players]

        Rails.logger.info "🏆 #{team.name}: #{players.map(&:name).join(', ')} (#{players.count} jogadores)"
      end

      # Simular envio de notificações para cada jogador
      game_session.session_participants.each do |player|
        notify_player(player, game_session, teams_with_players)
      end

      # Log de resumo
      total_players = game_session.session_participants.count
      total_teams = teams_with_players.count

      Rails.logger.info "✅ Notificações enviadas para #{total_players} jogadores em #{total_teams} times"

      # Enfileirar job de limpeza (opcional)
      TeamCleanupJob.set(wait: 1.hour).perform_later(game_session_id)

    rescue => e
      Rails.logger.error "❌ Erro ao enviar notificações: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
    end
  end

  private

  def notify_player(player, game_session, teams_with_players)
    # Encontrar o time do jogador
    player_team = teams_with_players.find { |t| t[:players].include?(player) }

    if player_team
      team = player_team[:team]
      teammates = player_team[:players].reject { |p| p == player }

      Rails.logger.info "📱 Notificação para #{player.name}: Você está no #{team.name} com #{teammates.map(&:name).join(', ')}"

      # Aqui você pode implementar notificações reais:
      # - Email: PlayerMailer.team_assignment(player, team, game_session).deliver_now
      # - Push notification: PushNotificationService.send(player, message)
      # - SMS: SmsService.send(player.phone, message)
      # - Webhook: WebhookService.notify(player, team, game_session)

      # Simular delay de envio
      sleep(0.1) if Rails.env.development?
    else
      Rails.logger.warn "⚠️ Jogador #{player.name} não encontrado em nenhum time"
    end
  end
end
