Rails.application.routes.draw do
  get "home/index"
  devise_for :users, skip: [ :registrations ]

  resources :tickets

  as :user do
    get "users/edit" => "devise/registrations#edit", as: "edit_user_registration"
    put "users" => "devise/registrations#update", as: "user_registration"
  end

  root to: "home#index"
end
