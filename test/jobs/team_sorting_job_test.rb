require "test_helper"

class TeamSortingJobTest < ActiveJob::TestCase
  def setup
    @game_session = game_sessions(:one)
    @player1 = players(:one)
    @player2 = players(:two)
    @player3 = players(:three)

    # Adicionar jogadores à sessão
    @game_session.add_player(@player1)
    @game_session.add_player(@player2)
    @game_session.add_player(@player3)
  end

  test "should sort teams successfully" do
    assert_difference 'Team.count', 1 do
      assert_difference 'TeamAssignment.count', 3 do
        TeamSortingJob.perform_now(@game_session.id, 2)
      end
    end

    @game_session.reload
    assert_equal 'in_progress', @game_session.status
    assert_equal 3, @game_session.total_players
    assert_equal 1, @game_session.total_teams
  end

  test "should create multiple teams when enough players" do
    # Adicionar mais jogadores para formar 2 times
    player4 = Player.create!(name: "Jogador 4", email: "j4@email.com", status: true)
    player5 = Player.create!(name: "Jogador 5", email: "j5@email.com", status: true)
    player6 = Player.create!(name: "Jogador 6", email: "j6@email.com", status: true)

    @game_session.add_player(player4)
    @game_session.add_player(player5)
    @game_session.add_player(player6)

    assert_difference 'Team.count', 2 do
      assert_difference 'TeamAssignment.count', 6 do
        TeamSortingJob.perform_now(@game_session.id, 3)
      end
    end

    @game_session.reload
    assert_equal 'in_progress', @game_session.status
    assert_equal 6, @game_session.total_players
    assert_equal 2, @game_session.total_teams
  end

  test "should fail when insufficient players" do
    # Remover jogadores para ter menos que o mínimo
    @game_session.session_players.destroy_all
    @game_session.add_player(@player1)

    assert_no_difference 'Team.count' do
      assert_no_difference 'TeamAssignment.count' do
        result = TeamSortingJob.perform_now(@game_session.id, 5)
        assert_equal false, result
      end
    end

    @game_session.reload
    assert_equal 'scheduled', @game_session.status
  end

  test "should clear existing assignments before sorting" do
    # Criar atribuições existentes
    team = Team.create!(name: "Time Existente")
    TeamAssignment.create!(
      player: @player1,
      team: team,
      game_session: @game_session
    )

    assert_difference 'Team.count', 1 do
      assert_difference 'TeamAssignment.count', 2 do # -1 (removido) + 3 (novos)
        TeamSortingJob.perform_now(@game_session.id, 2)
      end
    end
  end

  test "should enqueue notification job after sorting" do
    assert_enqueued_with(job: TeamNotificationJob) do
      TeamSortingJob.perform_now(@game_session.id, 2)
    end
  end

  test "should handle errors gracefully" do
    # Forçar erro passando ID inválido
    result = TeamSortingJob.perform_now(99999, 2)
    assert_equal false, result
  end
end
