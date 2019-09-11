class ChatkitAuthController < ApplicationController
  def create
    user = User.find_by(token: params[:token])
    auth_data = ChatkitService.connect.authenticate({
      user_id: user.id.to_s
    })

    render json: auth_data.body, status: auth_data.status
  end
end
