Rails.application.routes.draw do
  get "home/index"
  devise_for :users, skip: [ :registrations ]

  resources :tickets, only: [ :index, :new, :create, :show ]

  as :user do
    get "users/edit" => "devise/registrations#edit", as: "edit_user_registration"
    put "users" => "devise/registrations#update", as: "user_registration"
  end

  resources :tickets do
    resources :comments, only: [ :create ]
  end

  root to: "home#index"
end
