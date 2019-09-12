require 'rails/application_controller'

class ChatkitAuthController < Rails::ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    user = User.find_by(token: params[:token])

    if user
      auth_data = ChatkitService.connect.authenticate({ user_id: user.id.to_s })
      render json: auth_data.body, status: auth_data.status
    else
      render json: { error: 'Unauthorized' }, status: 401
    end
  end

  def show
    render file: Rails.root.join('/app/views/chatkit_auth', 'show.html')
  end
end
