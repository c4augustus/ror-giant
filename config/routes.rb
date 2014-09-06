RorGiant::Application.routes.draw do
  root 'welcome#index'
  resources :jobs, only: [:index, :show] do
    member do
      get 'apply'
      get 'tell'
    end
  end
end
