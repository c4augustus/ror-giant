RorGiant::Application.routes.draw do
  root 'welcome#index'
  resources :jobs, only: [:index, :show] do
    resources :job_applications,  only: :new,     to: 'jobs#application'
    resources :job_applications,  only: :create,  to: 'jobs#apply'
    resources :job_referrals,     only: :new,     to: 'jobs#referral'
    resources :job_referrals,     only: :create,  to: 'jobs#refer'
  end
end
