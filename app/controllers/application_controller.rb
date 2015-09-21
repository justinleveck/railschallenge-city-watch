class ApplicationController < ActionController::Base
  private

  def render_404
    render :file => 'public/404.json', :status => :not_found, :layout => false
  end

  def render_error_messages(model_instance)
    if model_instance
      base_error_message = model_instance.errors.messages[:base][0] if model_instance.errors.messages[:base]
      error_messages = { message: base_error_message || model_instance.errors.messages }
      render json: error_messages, status: 422
    end
  end
end
