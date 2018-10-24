Qpcrctl::Application.routes.draw do
  mount JasmineRails::Engine => '/specs' if defined?(JasmineRails)
  resources :posts

  apipie
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  root 'main#index'

  get '/welcome', :to => 'main#welcome', :as => 'welcome'
  get '/login', :to => 'main#login', :as => 'login'
  
  post '/login', :to => 'sessions#create'
  post '/logout', :to => 'sessions#destroy'

  get 'capabilities', to: "devices#capabilities"

  resource :device, only: [:show, :update] do
    get 'serial_start'
    get 'software_update'
    get 'status'
    put 'clean'
    put 'unserialize'
    put 'login'
    put 'root_password'
    post 'enable_support_access'
    get 'export_database'
  end
  
  resource :settings, only: [:update, :show]

  resources :users, defaults: { format: 'json' }

  resources :experiments, defaults: { format: 'json' } do
    member do
      post 'start'
      post 'stop'
      post 'resume'
      post 'copy'
      get 'well_layout'
      get 'temperature_data'
      get 'amplification_data'
      get 'melt_curve_data'
      get 'export'
      get 'analyze'
    end

    resources :samples, only: [:index, :create, :update, :destroy] do
      member do
        post 'links', to: 'samples#links'
        post 'unlinks', to: 'samples#unlinks'
      end
    end
    
    resources :targets
    resources :targets, only: [:index, :create, :update, :destroy] do
      member do
        post 'links', to: 'targets#links'
        post 'unlinks', to: 'targets#unlinks'
      end
    end
    
    resource :amplification_option, only: [:show, :update]
    
  end

  
  resources :protocols, shallow: true, only: [:update] do
    resources :stages, shallow: true, only: [:create, :update, :destroy] do
      resources :steps, shallow: true, only: [:create, :update, :destroy] do
        resources :ramps, only: [:update]
        post 'move', on: :member
      end
      post 'move', on: :member
    end
  end

  resources :apidocs, only: [:index]
  
  get ':controller(/:action(/:id))'
  
  match '/*path', :controller => 'main', :action => 'options', :via => [:options]
  
end
