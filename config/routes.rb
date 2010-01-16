ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # See how all your routes lay out with "rake routes"

  map.message 'message', :controller => 'message', :action => 'index'
  map.login 'login', :controller => 'account', :action => 'login'
  map.logout 'logout', :controller => 'account', :action => 'logout'
  map.my_profile 'my_profile', :controller => 'users', :action => 'my_profile'

  map.resources :projects, :active_scaffold => true do |projects|
   projects.resources :sprints, :active_scaffold => true do |sprints|
     sprints.day 'day/:day', :controller => 'sprints', :action => 'day' 
     sprints.empty_day 'day/', :controller => 'sprints', :action => 'day' 
   end

   projects.resources :duties, :active_scaffold => true
   projects.resources :stories, :active_scaffold => true
   projects.resources :tasks, :active_scaffold => true
  end

  map.project_stats_for_date '/projects/:id/stats_for_date/:date', :controller =>  'projects', :action => 'stats_for_date'

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.root :controller => 'projects', :action => 'index'
  
  map.resources :sprints, :active_scaffold => true
  map.resources :commitments, :active_scaffold => true
  map.resources :users, :active_scaffold => true
  map.resources :duties, :active_scaffold => true

  map.update_project_sprint_planning 'projects/:project_id/sprints/:id/planning', 
    :controller => 'sprints',
    :action => 'update',
    :mode => 'planning',
    :conditions => {:method => :put}

  map.project_sprint_current 'projects/:project_id/sprints/:id/current', 
    :controller => 'sprints',
    :action => 'show_current',
    :mode => 'current',
    :conditions => {:method => :get}

  map.project_sprint_planning 'projects/:project_id/sprints/:id/planning', 
    :controller => 'sprints',
    :action => 'show_planning',
    :mode => 'planning',
    :conditions => {:method => :get}

  map.project_sprint_closed 'projects/:project_id/sprints/:id/closed', 
    :controller => 'sprints',
    :action => 'show_closed',
    :mode => 'closed',
    :conditions => {:method => :get}

  map.edit_project_sprint_planning 'projects/:project_id/sprints/:id/planning/edit', 
    :controller => 'sprints', 
    :action => 'edit',
    :mode => 'planning'

  map.finish_planning_project_sprint 'projects/:project_id/sprints/:id/finish_planning', 
    :controller => 'sprints',
    :action => 'finish_planning',
    :conditions => {:method => :post}
  
  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
