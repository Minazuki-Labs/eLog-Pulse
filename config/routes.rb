Rails.application.routes.draw do
  get "home/index"
  devise_for :users, skip: [ :registrations ]

  get  "otp_login", to: "otp_sessions#new", as: :new_otp_login
  post "otp_login", to: "otp_sessions#create", as: :otp_login
  delete "otp_logout", to: "otp_sessions#destroy", as: :otp_logout

  as :user do
    get "users/edit" => "devise/registrations#edit", as: "edit_user_registration"
    put "users" => "devise/registrations#update", as: "user_registration"
  end

  resources :users do
    collection do
      get :schools
      get :new_school
      post :create_school
    end
  end

  resources :tickets do
    resources :comments, only: [ :create ]

    collection do
      get :locations
      get :equipment
      get :issue_types
    end
  end

  root to: "home#index"
end
