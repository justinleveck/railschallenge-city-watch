Rails.application.routes.draw do
  resources :emergencies, only: [:index, :show, :new, :update, :create, :edit, :destroy], param: :code
  resources :responders, only: [:index, :show, :new, :update, :create, :edit, :destroy], param: :name
end
