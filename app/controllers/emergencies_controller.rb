class EmergenciesController < ApplicationController
  def index
    @emergencies = Emergency.all
    @full_responses = Emergency.full_responses
    render action: 'index', formats: 'json'
  end

  def show
    @emergency = Emergency.find_by_code(params[:code])
    @full_responses = Emergency.full_responses

    if @emergency
      render action: 'show', formats: 'json'
    else
      render_404
    end
  end

  def new
    render_404
  end

  def edit
    render_404
  end

  def create
    @emergency = Emergency.new(emergency_params) if emergency_params.present?

    if params_permitted? && @emergency.save
      @responders = @emergency.responders.map(&:name).as_json
      @full_responses = Emergency.full_responses if Responder.where(emergency_code: nil, on_duty: true).count > 0
      render action: 'show', formats: 'json', status: 201
    else
      render_error_messages(@emergency)
    end
  end

  def update
    @emergency = Emergency.find_by_code(params[:code])
    @full_responses = Emergency.full_responses

    if params_permitted? && @emergency.update_attributes(emergency_params)
      render action: 'show', formats: 'json', status: 201
    else
      render_error_messages(@emergency)
    end
  end

  def destroy
    render_404
  end

  private

  def unpermitted_params
    unpermitted_update_params = []

    if action_name == "update"
      unpermitted_update_params << "code" if emergency_params[:code].present?
    elsif action_name == "create"
      unpermitted_update_params << "resolved_at" if emergency_params[:resolved_at].present?
    end

    super + unpermitted_update_params
  end

  def emergency_params
    params.require(:emergency).permit(:code, :fire_severity, :police_severity, :medical_severity, :resolved_at)
  end
end
