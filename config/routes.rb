Rails.application.routes.draw do

  devise_for :users, :controllers => { :omniauth_callbacks => "callbacks" }

  root 'welcome#index'

  resources :events, only: [:create, :edit, :update, :destroy, :index] do
    collection do
      get :data_table
    end

    member do
      get :data_table
    end
  end

  resources :vacation_requests, only: [:create, :edit, :update, :destroy, :index]

  resources :feedbacks, only: [:create]

  resources :rooms, only: [:show]

  mount ActionCable.server => '/cable'

  namespace :admin do
    get '/' => 'dashboard#index', as: :dashboard

    resources :feedbacks, only: [:index] do
      member do
        patch :dismissed
        patch :in_progress
        patch :resolved
      end
    end

    resources :projects, param: :slug, sexcept: [:show, :new, :update] do
      member do
        get :report
      end

      collection do
        post :add_user
        patch :remove_user
      end
    end

    resources :vacation_requests, only: [:index] do
      collection do
        post :accept
        post :decline
        post :holiday
      end
    end

    resources :users, except: [:new, :create] do
      collection do
        post :add_rate
      end

      member do
        post :update_project
        patch :remove_project
        patch :set_limit
        post :add_project
        get :event_table, controller: :events
      end
    end

    resources :reports, only: [:index]
  end
end
