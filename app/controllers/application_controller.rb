class ApplicationController < ActionController::Base
  private

  def render_404
    render file: 'public/404.json', status: :not_found, layout: false
  end

  def render_error_messages(model_instance)
    return if model_instance.nil?

    error_messages = { message: @unpermitted_param_errors || model_instance.errors.messages }
    render json: error_messages, status: 422
  end
end
