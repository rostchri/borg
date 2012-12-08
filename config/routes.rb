Borg::Application.routes.draw do
  
  # all ajax-actions
  match '/ajax/moviedetails/:id/:md' => 'ajax#moviedetails', :as => :moviedetails, :id => /[^\/]+/
  match '/ajax/autocomplete/titlesearch/:title' => 'ajax#autocomplete_titlesearch', :title => /[^\/]+/ 
  match '/ajax/autocomplete/plotsearch/:plot' => 'ajax#autocomplete_plotsearch', :plot => /[^\/]+/ 
  
  resources :mediafiles do
    get 'page/:page', :action => :index, :on => :collection
    collection do
      get "video_thumbnail"
      get "fanart_thumbnail"
    end
  end

  resources :mediapath do
    get 'page/:page', :action => :index, :on => :collection
  end

  resources :movies do
    get 'page/:page', :action => :index, :on => :collection
    collection do
      get "overview"
    end
  end

  resources :genres do
    get 'page/:page', :action => :index, :on => :collection
  end
  
  resources :users do
    get 'page/:page', :action => :index, :on => :collection
  end
  
  resources :user_sessions
  match 'login'  => "user_sessions#new",     :as => :login
  match 'logout' => "user_sessions#destroy", :as => :logout
  
  
  root :to => 'movies#overview'
  
end
