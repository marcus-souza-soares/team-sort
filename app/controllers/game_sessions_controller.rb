class GameSessionsController < ApplicationController
  before_action :set_game_session, only: %i[ show edit update destroy sort_teams manage_players add_player remove_player sort_teams_form ]

  # GET /game_sessions or /game_sessions.json
  def index
    @game_sessions = GameSession.all.order(date: :desc)
  end

  # GET /game_sessions/1 or /game_sessions/1.json
  def show
    @teams = @game_session.teams.includes(:players).distinct
    @total_players = @game_session.total_players
    @total_teams = @game_session.total_teams
    @session_participants = @game_session.session_participants.distinct
  end

  # GET /game_sessions/new
  def new
    @game_session = GameSession.new
    @game_session.date = DateTime.current
    @game_session.status = 'scheduled'
  end

  # GET /game_sessions/1/edit
  def edit
  end

  # POST /game_sessions or /game_sessions.json
  def create
    @game_session = GameSession.new(game_session_params)

    respond_to do |format|
      if @game_session.save
        format.html { redirect_to @game_session, notice: "Sessão de jogo criada com sucesso." }
        format.json { render :show, status: :created, location: @game_session }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @game_session.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /game_sessions/1 or /game_sessions/1.json
  def update
    respond_to do |format|
      if @game_session.update(game_session_params)
        format.html { redirect_to @game_session, notice: "Sessão de jogo atualizada com sucesso." }
        format.json { render :show, status: :ok, location: @game_session }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @game_session.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /game_sessions/1 or /game_sessions/1.json
  def destroy
    @game_session.destroy!

    respond_to do |format|
      format.html { redirect_to game_sessions_path, status: :see_other, notice: "Sessão de jogo removida com sucesso." }
      format.json { head :no_content }
    end
  end

  # GET /game_sessions/1/sort_teams_form
  def sort_teams_form
    @total_players = @game_session.total_players
    @max_players_per_team = [@total_players, 10].min
    @min_players_per_team = 2
  end

  # POST /game_sessions/1/sort_teams
  def sort_teams
    binding.irb
    players_per_team = params[:players_per_team].to_i

    if players_per_team < 2
      redirect_to sort_teams_form_game_session_path(@game_session), alert: "Mínimo de 2 jogadores por time."
      return
    end

    if !@game_session.can_start?(players_per_team)
      redirect_to sort_teams_form_game_session_path(@game_session), alert: "Jogadores insuficientes para formar times com #{players_per_team} jogadores cada."
      return
    end

    result = TeamSorterService.sort_teams_for_session(@game_session, players_per_team)

    respond_to do |format|
      if result[:success]
        format.html { redirect_to @game_session, notice: result[:message] }
        format.json { render json: result }
      else
        format.html { redirect_to sort_teams_form_game_session_path(@game_session), alert: result[:message] }
        format.json { render json: result, status: :unprocessable_entity }
      end
    end
  end

  # GET /game_sessions/1/manage_players
  def manage_players
    @available_players = Player.active.where.not(id: @game_session.session_participants.pluck(:id))
    @session_participants = @game_session.session_participants
  end

  # POST /game_sessions/1/add_player
  def add_player
    player = Player.find(params[:player_id])

    if @game_session.add_player(player)
      redirect_to manage_players_game_session_path(@game_session), notice: "#{player.name} adicionado à sessão."
    else
      redirect_to manage_players_game_session_path(@game_session), alert: "Erro ao adicionar jogador."
    end
  end

  # DELETE /game_sessions/1/remove_player
  def remove_player
    player = Player.find(params[:player_id])

    if @game_session.remove_player(player)
      redirect_to manage_players_game_session_path(@game_session), notice: "#{player.name} removido da sessão."
    else
      redirect_to manage_players_game_session_path(@game_session), alert: "Erro ao remover jogador."
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_game_session
      @game_session = GameSession.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def game_session_params
      params.expect(game_session: [ :date, :status ])
    end
end
