Rails.application.routes.draw do
  get "home/index"
  devise_for :users, skip: [ :registrations ]

  as :user do
    get "account/edit" => "devise/registrations#edit", as: "edit_user_registration"
    put "account" => "devise/registrations#update", as: "user_registration"
  end

  resources :users do
    member do
      get :edit_assignment
      patch :update_assignment
      patch :toggle_role
    end

    resources :locations, only: [ :index, :new, :create, :show, :edit, :update, :destroy ] do
      member do
        patch :update_equipment
      end
      resources :equipment, only: [ :create, :destroy ]
    end

    collection do
      get :schools
      get :new_school
      post :create_school

      get :employees
      get :new_employee
      post :create_employee
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

  resources :equipment_categories, only: [ :index, :show, :new, :create, :edit, :update, :destroy ]

  root to: "home#index"
end
