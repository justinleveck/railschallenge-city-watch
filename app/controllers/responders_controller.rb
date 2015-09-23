class RespondersController < ApplicationController
  def index
    @responders = Responder.all
    render action: 'index', formats: 'json'
  end

  def show
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
  end

  def destroy
    render_404
  end

  private

  def responder_params
    params.require(:responder).permit(:type, :name, :capacity)
  end
end
