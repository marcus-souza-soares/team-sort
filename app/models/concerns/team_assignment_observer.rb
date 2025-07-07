module TeamAssignmentObserver
  extend ActiveSupport::Concern

  included do
    # Observer Callbacks - Monitoram mudanças e executam ações
    after_create :log_player_assignment
    after_update :log_assignment_change
    after_destroy :log_player_removal

    # Callback para atualizar estatísticas da sessão
    after_commit :update_session_statistics, on: [:create, :update, :destroy]

    # Callback para notificar mudanças importantes
    after_commit :notify_team_changes, on: [:create, :destroy]
  end

  private

  # Observer: Log de atribuição de jogador
  def log_player_assignment
    Rails.logger.info "🎯 Jogador #{player.name} foi atribuído ao time #{team.name} na sessão #{game_session.date.strftime('%d/%m/%Y')}"

    # Pode ser expandido para salvar em uma tabela de logs
    # ActivityLog.create(
    #   action: 'player_assigned',
    #   player: player,
    #   team: team,
    #   game_session: game_session,
    #   details: "Jogador #{player.name} foi atribuído ao time #{team.name}"
    # )
  end

  # Observer: Log de mudança de atribuição
  def log_assignment_change
    if saved_change_to_team_id?
      old_team = Team.find_by(id: team_id_previous_change&.first)
      Rails.logger.info "🔄 Jogador #{player.name} foi transferido do time #{old_team&.name} para #{team.name} na sessão #{game_session.date.strftime('%d/%m/%Y')}"
    end
  end

  # Observer: Log de remoção de jogador
  def log_player_removal
    Rails.logger.info "❌ Jogador #{player.name} foi removido do time #{team.name} na sessão #{game_session.date.strftime('%d/%m/%Y')}"
  end

  # Observer: Atualizar estatísticas da sessão
  def update_session_statistics
    game_session.touch # Atualiza updated_at para invalidar cache se necessário

    # Recalcula estatísticas da sessão
    total_players = game_session.team_assignments.count
    total_teams = game_session.teams.distinct.count

    Rails.logger.info "📊 Estatísticas atualizadas - Sessão #{game_session.date.strftime('%d/%m/%Y')}: #{total_players} jogadores em #{total_teams} times"
  end

  # Observer: Notificar mudanças importantes
  def notify_team_changes
    case
    when created?
      notify_player_assigned
    when destroyed?
      notify_player_removed
    end
  end

  def notify_player_assigned
    # Simula notificação (pode ser expandido para email, push notification, etc.)
    Rails.logger.info "🔔 NOTIFICAÇÃO: #{player.name} foi adicionado ao time #{team.name}"

    # Exemplo de como seria uma notificação real:
    # NotificationService.new(player).notify_assignment(team, game_session)
  end

  def notify_player_removed
    Rails.logger.info "🔔 NOTIFICAÇÃO: #{player.name} foi removido do time #{team.name}"
  end
end
