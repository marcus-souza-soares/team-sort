require "test_helper"

class TeamAssignmentTest < ActiveSupport::TestCase
  def setup
    @player = players(:one)
    @team = teams(:one)
    @game_session = game_sessions(:one)
  end

  test "should create team assignment with observer logging" do
    # Captura logs para verificar se o observer está funcionando
    log_output = capture_logs do
      @team_assignment = TeamAssignment.create!(
        player: @player,
        team: @team,
        game_session: @game_session
      )
    end

    assert @team_assignment.persisted?
    assert_includes log_output, "🎯 Jogador #{@player.name} foi atribuído ao time #{@team.name}"
    assert_includes log_output, "📊 Estatísticas atualizadas"
    assert_includes log_output, "🔔 NOTIFICAÇÃO: #{@player.name} foi adicionado ao time #{@team.name}"
  end

  test "should update team assignment with observer logging" do
    @team_assignment = TeamAssignment.create!(
      player: @player,
      team: @team,
      game_session: @game_session
    )

    new_team = teams(:two)

    log_output = capture_logs do
      @team_assignment.update!(team: new_team)
    end

    assert_includes log_output, "🔄 Jogador #{@player.name} foi transferido do time #{@team.name} para #{new_team.name}"
    assert_includes log_output, "📊 Estatísticas atualizadas"
  end

  test "should destroy team assignment with observer logging" do
    @team_assignment = TeamAssignment.create!(
      player: @player,
      team: @team,
      game_session: @game_session
    )

    log_output = capture_logs do
      @team_assignment.destroy
    end

    assert_includes log_output, "❌ Jogador #{@player.name} foi removido do time #{@team.name}"
    assert_includes log_output, "📊 Estatísticas atualizadas"
    assert_includes log_output, "🔔 NOTIFICAÇÃO: #{@player.name} foi removido do time #{@team.name}"
  end

  test "should update session statistics after assignment changes" do
    # Criar múltiplas atribuições para testar estatísticas
    player2 = players(:two)
    player3 = players(:three)

    log_output = capture_logs do
      TeamAssignment.create!(player: @player, team: @team, game_session: @game_session)
      TeamAssignment.create!(player: player2, team: @team, game_session: @game_session)
      TeamAssignment.create!(player: player3, team: @team, game_session: @game_session)
    end

    # Verificar se as estatísticas foram atualizadas
    assert_includes log_output, "📊 Estatísticas atualizadas"

    # Verificar se o game_session foi atualizado (touch)
    @game_session.reload
    assert_not_nil @game_session.updated_at
  end

  test "should validate player uniqueness in same session" do
    # Criar primeira atribuição
    TeamAssignment.create!(
      player: @player,
      team: @team,
      game_session: @game_session
    )

    # Tentar criar segunda atribuição do mesmo jogador na mesma sessão
    second_assignment = TeamAssignment.new(
      player: @player,
      team: @team,
      game_session: @game_session
    )

    assert_not second_assignment.valid?
    assert_includes second_assignment.errors[:player_id], "já está atribuído a este time nesta sessão"
  end

  test "should validate player not in multiple teams same session" do
    team2 = teams(:two)

    # Criar primeira atribuição
    TeamAssignment.create!(
      player: @player,
      team: @team,
      game_session: @game_session
    )

    # Tentar criar segunda atribuição do mesmo jogador em time diferente na mesma sessão
    second_assignment = TeamAssignment.new(
      player: @player,
      team: team2,
      game_session: @game_session
    )

    assert_not second_assignment.valid?
    assert_includes second_assignment.errors[:player], "já está em outro time nesta sessão"
  end

  private

  def capture_logs
    log_output = StringIO.new
    Rails.logger = Logger.new(log_output)
    Rails.logger.level = Logger::INFO

    yield

    log_output.string
  ensure
    Rails.logger = Logger.new(STDOUT)
  end
end
