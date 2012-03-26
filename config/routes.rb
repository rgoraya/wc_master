Wikicausality::Application.routes.draw do

  match '/signup', :to  => 'users#new' 
  resources :game
  match 'mapvisualizations/search_bars' => 'mapvisualizations#search_bars'
  match 'mapvisualizations/qtip' => 'mapvisualizations#qtip'
  resources :mapvisualizations
  resources :paths
  resources :feed_backs
  resources :suggestions
	resources :feedbacks
  
  get "suggestions/:id/reject" => "suggestions#reject"

  resources :references
  resources :comments
  resources :votes
	#post "comments" => "comments#create"

  get "pages/home"

  get "pages/contact"

  get "pages/about"

  root :to => "pages#home"
  match 'about' => 'pages#about', :as => :about
  match 'contact' => 'pages#contact', :as => :contact
  

  resources :users

  resources :user_sessions
  
  match '/relationships/page/:page', :controller => 'relationships', :action => 'index'
  resources :relationships
  
  
  match 'issues/auto_complete_search' => 'issues#auto_complete_search'
  match 'issues/get_relationship' => 'issues#get_relationship'
  resources :issues do
    post :create_reference, :on => :member
  end
  
  get "issues/:id/versions" => "issues#versions", :as => "issue_versions"
  get "versions/:id/restore" => "versions#restore", :as => "restore_version"
  get "issues/:id/snapshot/:at" => "issues#snapshot", :as => "issue_snapshot"
	get "users/:id/activities" => "users#activities", :as => "user_activities"


  match 'login' => 'user_sessions#new', :as => :login
  match 'logout' => 'user_sessions#destroy', :as => :logout

	get "api" => "gate#get"
	post "api" => "gate#post"

	get "all/stats" => "pages#stats"

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
