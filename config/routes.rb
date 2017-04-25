RorGiant::Application.routes.draw do
  root 'welcome#index'
  resources :talent_requests, only: [:new, :create]
  resources :jobs, only: [:index, :show] do
    resources :job_applications,  only: :new,     to: 'jobs#jobapp'
    resources :job_applications,  only: :create,  to: 'jobs#jobapply'
    resources :job_referrals,     only: :new,     to: 'jobs#referral'
    resources :job_referrals,     only: :create,  to: 'jobs#refer'
  end
end
