Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  # health controller
  get '/health', to: 'health#show'

  # auth controller
  scope :auth do
    post '/register', to: 'auth#register'
    post '/login', to: 'auth#login'
    post '/logout', to: 'auth#logout'
    post '/refresh', to: 'auth#refresh'
    get '/me', to: 'auth#me'
  end

  # conversations controller
  resources :conversations, only: [:index, :show, :create] do
    resources :messages, only: [:index]
  end

  # messages controller
  resources :messages, only: [:create] do
    member do
      put 'read'
    end
  end

  namespace :expert do
    get 'queue'
    post 'conversations/:conversation_id/claim', to: 'conversations#claim'
    post 'conversations/:conversation_id/unclaim', to: 'conversations#unclaim'
    resource :profile, only: [:show, :update]
    namespace :assignments do
      get 'history'
    end
  end

  namespace :api do
    get 'conversations/updates', to: 'updates#conversations'
    get 'messages/updates', to: 'updates#messages'
    get 'expert-queue/updates', to: 'updates#expert_queue'
  end
end
