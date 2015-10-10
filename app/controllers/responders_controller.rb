class RespondersController < ApplicationController
  def index
    if params[:show] == 'capacity'
      @capacity = Responder.capacities
      render 'capacity', formats: 'json'
    else
      @responders = Responder.all
      render action: 'index', formats: 'json'
    end
  end

  def show
    @responder = Responder.find_by_name(params[:name])

    if @responder
      render action: 'show', formats: 'json', status: 201
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
    @responder = Responder.new(responder_params) if responder_params.present?

    if params_permitted? && @responder.save
      render action: 'show', formats: 'json', status: 201
    else
      render_error_messages(@responder)
    end
  end

  def update
    @responder = Responder.find_by_name(params[:name])

    if params_permitted? && @responder.update_attributes(responder_params)
      render action: 'show', formats: 'json', status: 201
    else
      render_error_messages(@responder)
    end
  end

  def destroy
    render_404
  end

  private

  def responder_params
    if action_name == "update"
      params.require(:responder).permit(:on_duty)
    else
      params.require(:responder).permit(:type, :name, :capacity)
    end
  end
end
