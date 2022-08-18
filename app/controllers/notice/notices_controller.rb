class Notice::NoticesController < ApplicationController

  load_and_authorize_resource
  before_action :set_notice, only: %i[ show update destroy ]

  def index
    @notices = Notice.includes(user: [:role]).all if user_admin or user_student
    @notices = Notice.includes(user: [:role]).where(user: current_user.id) if user_teacher
    render json: show_all_notices
  end

  def show
    render json: show_notice
  end

  def create
    @notice = Notice.new(notice_params)
    @notice.user = current_user
    if @notice.save
      render json: { message: "Notice was created sucessfully!" , notice: show_notice}
    else
      handle_error @notice.errors
    end
  end

  def update
    if @notice.update(notice_params)
      render json: { message: "Notice was edited sucessfully!" , notice: show_notice}, status: :ok, location: @notice
    else
      handle_error @notice.errors
    end
  end

  def destroy
    if @notice.destroy
      success_response("Notice was deleted | Notice ID: #{@notice.id}")
    else
      faliure_response("Error Occured!, can't delete notice")
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_notice
      @notice = Notice.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def notice_params
      params.require(:notice).permit(:title, :description, :user_id)
    end

    def show_notice
      {
        id: @notice.id,
        title: @notice.title,
        description: @notice.description,
        user: @notice.user.name,
        user_role: @notice.user.role.name,
        url: notice_url(@notice),
        created_at: @notice.created_at,
        updated_at: @notice.updated_at
      }
    end
end
