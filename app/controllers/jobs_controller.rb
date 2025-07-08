class JobsController < ApplicationController
  before_action :set_game_session, only: [:sort_teams, :send_notifications, :cleanup_session]

  def index
    @game_sessions = GameSession.includes(:session_participants).order(date: :desc)
  end

  def sort_teams
    players_per_team = params[:players_per_team]&.to_i || 5

    if @game_session.can_start?(players_per_team)
      # Enfileirar job de sorteio
      job = TeamSortingJob.perform_later(@game_session.id, players_per_team)

      redirect_to @game_session, notice: "Sorteio de times iniciado! Job ID: #{job.job_id}"
    else
      redirect_to @game_session, alert: "Sessão não pode ser iniciada. Mínimo de #{players_per_team * 2} jogadores necessários."
    end
  end

  def send_notifications
    # Enfileirar job de notificação
    job = TeamNotificationJob.perform_later(@game_session.id)

    redirect_to @game_session, notice: "Notificações sendo enviadas! Job ID: #{job.job_id}"
  end

  def cleanup_session
    # Enfileirar job de limpeza
    job = TeamCleanupJob.perform_later(@game_session.id)

    redirect_to @game_session, notice: "Limpeza da sessão iniciada! Job ID: #{job.job_id}"
  end

  def cleanup_all
    # Enfileirar job de limpeza geral
    job = TeamCleanupJob.perform_later

    redirect_to jobs_path, notice: "Limpeza geral iniciada! Job ID: #{job.job_id}"
  end

  def status
    # Verificar se o Sidekiq está disponível e funcionando
    begin
      if defined?(Sidekiq) && defined?(Sidekiq::Queue)
        # Tentar conectar ao Redis e verificar filas
        @pending_jobs = Sidekiq::Queue.new.size
        @scheduled_jobs = defined?(Sidekiq::ScheduledSet) ? Sidekiq::ScheduledSet.new.size : 0
        @retry_jobs = defined?(Sidekiq::RetrySet) ? Sidekiq::RetrySet.new.size : 0
        @sidekiq_available = true
        @status_message = "Sidekiq funcionando normalmente"
      else
        @pending_jobs = 0
        @scheduled_jobs = 0
        @retry_jobs = 0
        @sidekiq_available = false
        @status_message = "Sidekiq não está configurado"
      end
    rescue Redis::CannotConnectError => e
      Rails.logger.error "Erro de conexão com Redis: #{e.message}"
      @pending_jobs = 0
      @scheduled_jobs = 0
      @retry_jobs = 0
      @sidekiq_available = false
      @status_message = "Redis não está disponível"
    rescue => e
      Rails.logger.error "Erro ao acessar Sidekiq: #{e.message}"
      @pending_jobs = 0
      @scheduled_jobs = 0
      @retry_jobs = 0
      @sidekiq_available = false
      @status_message = "Erro ao conectar com Sidekiq"
    end

    render json: {
      pending: @pending_jobs,
      scheduled: @scheduled_jobs,
      retry: @retry_jobs,
      sidekiq_available: @sidekiq_available,
      status_message: @status_message
    }
  end

  private

  def set_game_session
    @game_session = GameSession.find(params[:game_session_id])
  end
end
