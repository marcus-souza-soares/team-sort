class TeamAssignmentsController < ApplicationController
  before_action :set_team_assignment, only: %i[ show edit update destroy ]

  # GET /team_assignments or /team_assignments.json
  def index
    @team_assignments = TeamAssignment.all
  end

  # GET /team_assignments/1 or /team_assignments/1.json
  def show
  end

  # GET /team_assignments/new
  def new
    @team_assignment = TeamAssignment.new
  end

  # GET /team_assignments/1/edit
  def edit
  end

  # POST /team_assignments or /team_assignments.json
  def create
    @team_assignment = TeamAssignment.new(team_assignment_params)

    respond_to do |format|
      if @team_assignment.save
        format.html { redirect_to @team_assignment, notice: "Team assignment was successfully created." }
        format.json { render :show, status: :created, location: @team_assignment }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @team_assignment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /team_assignments/1 or /team_assignments/1.json
  def update
    respond_to do |format|
      if @team_assignment.update(team_assignment_params)
        format.html { redirect_to @team_assignment, notice: "Team assignment was successfully updated." }
        format.json { render :show, status: :ok, location: @team_assignment }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @team_assignment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /team_assignments/1 or /team_assignments/1.json
  def destroy
    @team_assignment.destroy!

    respond_to do |format|
      format.html { redirect_to team_assignments_path, status: :see_other, notice: "Team assignment was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_team_assignment
      @team_assignment = TeamAssignment.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def team_assignment_params
      params.expect(team_assignment: [ :player_id, :team_id, :game_session_id ])
    end
end
