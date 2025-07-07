require "test_helper"

class TeamAssignmentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @team_assignment = team_assignments(:one)
  end

  test "should get index" do
    get team_assignments_url
    assert_response :success
  end

  test "should get new" do
    get new_team_assignment_url
    assert_response :success
  end

  test "should create team_assignment" do
    assert_difference("TeamAssignment.count") do
      post team_assignments_url, params: { team_assignment: { game_session_id: @team_assignment.game_session_id, player_id: @team_assignment.player_id, team_id: @team_assignment.team_id } }
    end

    assert_redirected_to team_assignment_url(TeamAssignment.last)
  end

  test "should show team_assignment" do
    get team_assignment_url(@team_assignment)
    assert_response :success
  end

  test "should get edit" do
    get edit_team_assignment_url(@team_assignment)
    assert_response :success
  end

  test "should update team_assignment" do
    patch team_assignment_url(@team_assignment), params: { team_assignment: { game_session_id: @team_assignment.game_session_id, player_id: @team_assignment.player_id, team_id: @team_assignment.team_id } }
    assert_redirected_to team_assignment_url(@team_assignment)
  end

  test "should destroy team_assignment" do
    assert_difference("TeamAssignment.count", -1) do
      delete team_assignment_url(@team_assignment)
    end

    assert_redirected_to team_assignments_url
  end
end
