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

  def unpermitted_params
    request.request_parameters[request.request_parameters.first[0]].keys - send("#{controller_name.singularize}_params").keys
  end

  def params_permitted?
    @unpermitted_param_errors = nil
    unpermitted_params.each do |unpermitted_param|
      @unpermitted_param_errors ||= "found unpermitted parameter: #{unpermitted_param}"
    end

    @unpermitted_param_errors.nil?
  end
end
