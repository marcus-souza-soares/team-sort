class TeamCleanupJob < ApplicationJob
  queue_as :maintenance

  def perform(game_session_id = nil)
    if game_session_id
      cleanup_specific_session(game_session_id)
    else
      cleanup_all_sessions
    end
  end

  private

  def cleanup_specific_session(game_session_id)
    game_session = GameSession.find(game_session_id)

    Rails.logger.info "🧹 Iniciando limpeza da sessão #{game_session.id}"

    begin
      # Limpar times órfãos (sem jogadores)
      orphaned_teams = game_session.teams.left_joins(:team_assignments)
                                   .where(team_assignments: { id: nil })

      orphaned_count = orphaned_teams.count
      orphaned_teams.destroy_all

      Rails.logger.info "🗑️ Removidos #{orphaned_count} times órfãos"

      # Limpar atribuições inválidas
      invalid_assignments = game_session.team_assignments
                                       .left_joins(:player)
                                       .where(players: { id: nil })

      invalid_count = invalid_assignments.count
      invalid_assignments.destroy_all

      Rails.logger.info "🗑️ Removidas #{invalid_count} atribuições inválidas"

      # Recalcular estatísticas
      total_players = game_session.session_participants.count
      total_teams = game_session.teams.count

      Rails.logger.info "📊 Estatísticas finais: #{total_players} jogadores em #{total_teams} times"

    rescue => e
      Rails.logger.error "❌ Erro na limpeza da sessão #{game_session_id}: #{e.message}"
    end
  end

  def cleanup_all_sessions
    Rails.logger.info "🧹 Iniciando limpeza geral de todas as sessões"

    begin
      # Limpar sessões antigas (mais de 30 dias)
      old_sessions = GameSession.where('date < ?', 30.days.ago)
      old_count = old_sessions.count

      old_sessions.each do |session|
        session.team_assignments.destroy_all
        session.teams.destroy_all
        session.session_players.destroy_all
      end

      Rails.logger.info "🗑️ Limpadas #{old_count} sessões antigas"

      # Limpar times órfãos globais
      orphaned_teams = Team.left_joins(:team_assignments)
                          .where(team_assignments: { id: nil })

      orphaned_count = orphaned_teams.count
      orphaned_teams.destroy_all

      Rails.logger.info "🗑️ Removidos #{orphaned_count} times órfãos globais"

      # Estatísticas gerais
      total_sessions = GameSession.count
      total_players = Player.count
      total_teams = Team.count

      Rails.logger.info "📊 Estatísticas gerais: #{total_sessions} sessões, #{total_players} jogadores, #{total_teams} times"

    rescue => e
      Rails.logger.error "❌ Erro na limpeza geral: #{e.message}"
    end
  end
end
