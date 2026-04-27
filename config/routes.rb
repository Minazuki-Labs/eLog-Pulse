Rails.application.routes.draw do
  get "home/index"
  devise_for :users, skip: [ :registrations ]

  as :user do
    get "users/edit" => "devise/registrations#edit", as: "edit_user_registration"
    put "users" => "devise/registrations#update", as: "user_registration"
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
