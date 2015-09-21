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

   if @emergency.save
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
    params.require(:emergency).permit(:id, :code, :fire_severity, :police_severity, :medical_severity, :resolved_at)
  end
end
