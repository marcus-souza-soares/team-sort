require "application_system_test_case"

class TeamAssignmentsTest < ApplicationSystemTestCase
  setup do
    @team_assignment = team_assignments(:one)
  end

  test "visiting the index" do
    visit team_assignments_url
    assert_selector "h1", text: "Team assignments"
  end

  test "should create team assignment" do
    visit team_assignments_url
    click_on "New team assignment"

    fill_in "Game session", with: @team_assignment.game_session_id
    fill_in "Player", with: @team_assignment.player_id
    fill_in "Team", with: @team_assignment.team_id
    click_on "Create Team assignment"

    assert_text "Team assignment was successfully created"
    click_on "Back"
  end

  test "should update Team assignment" do
    visit team_assignment_url(@team_assignment)
    click_on "Edit this team assignment", match: :first

    fill_in "Game session", with: @team_assignment.game_session_id
    fill_in "Player", with: @team_assignment.player_id
    fill_in "Team", with: @team_assignment.team_id
    click_on "Update Team assignment"

    assert_text "Team assignment was successfully updated"
    click_on "Back"
  end

  test "should destroy Team assignment" do
    visit team_assignment_url(@team_assignment)
    accept_confirm { click_on "Destroy this team assignment", match: :first }

    assert_text "Team assignment was successfully destroyed"
  end
end
