class EmergenciesController < ApplicationController
  def index
  end

  def show
    @emergency = Emergency.find_by_code(code)
    render action: 'show', formats: 'json'
  end

  def new
    render_404
  end

  def create
   if emergency_params.present?
     @emergency = Emergency.new(emergency_params)
   end

   if params_permitted? && @emergency.save
     render action: 'show', formats: 'json', status: 201
   else
     render_error_messages(@emergency)
   end
  end

  def edit
    render_404
  end

  def destroy
    render_404
  end

  private

  def emergency_params
    params.require(:emergency).permit(:code, :fire_severity, :police_severity, :medical_severity)
  end

  def unpermitted_params
    request.request_parameters[request.request_parameters.first[0]].keys - emergency_params.keys
  end

  def params_permitted?
    @unpermitted_param_errors = nil
    unpermitted_params.each do |unpermitted_param|
      @unpermitted_param_errors ||= "found unpermitted parameter: #{unpermitted_param}"
      return false
    end

    return true
  end
end
