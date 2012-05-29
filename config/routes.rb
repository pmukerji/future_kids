FutureKids::Application.routes.draw do

  devise_for :users

  root :to => 'kids#index'
  resources :admins
  resources :documents
  resources :mentors do
    member do
       get 'edit_schedules'
       put 'update_schedules'
    end
  end
  resources :kids do
    resources :journals do
      resources :comments
    end
    resources :reviews
    member do
       get 'edit_schedules'
       put 'update_schedules'
    end
  end
  resources :schedules
  resources :reminders
  resources :teachers

  match '/exception_test' => 'exception_test#error'
end
