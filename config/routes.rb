Rails.application.routes.draw do
  resources :emergencies, only: [:index, :show, :new, :create, :edit, :destroy], param: :code
  resources :responders, only: [:index, :new, :create, :edit, :destroy], param: :code
end
