Rails.application.routes.draw do
  root 'projects#index'
  post 'deployments/:id/trigger_deployment', to: 'deployments#trigger_deployment', as: 'deployment_trigger'
  get 'deployments/job_trace/:id', to: 'deployments#job_trace', as: 'job_trace'
  resources :users, only: [:edit, :update]do
    resources :projects, only: [:index, :show] do
      resources :commits, only: [:index, :show]
    end
  end
  resources :deployments, only: [:new, :create, :index, :show, :update]
  devise_for :users, contollers: {cas_sessions: 'sessions'}
end
