class EmergenciesController < ApplicationController
  def index
    @emergencies = Emergency.all
    render action: 'index', formats: 'json'
  end

  def show
    @emergency = Emergency.find_by_code(params[:code])

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
      render action: 'show', formats: 'json', status: 201
    else
      render_error_messages(@emergency)
    end
  end

  def update
  end

  def destroy
    render_404
  end

  private

  def emergency_params
    params.require(:emergency).permit(:code, :fire_severity, :police_severity, :medical_severity)
  end
end
