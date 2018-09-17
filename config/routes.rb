Rails.application.routes.draw do
  root   'static_pages#home'
  get    '/signup',  to: 'users#new'
  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'
  # get '/attendance_edit', to: 'users#show'

  # 基本情報編集画面  
  get '/basic_info',      to: 'users#edit_basic_info'
  post'/basic_info_edit', to: 'users#basic_info_edit'
  
  # 出退勤ボタン
  post '/timein_creat',  to: 'users#time_in'
  post '/timeout_creat', to: 'users#time_out'
  
  # 勤怠編集画面
  get '/attendance_edit', to: 'attendances#attendance_edit'
  post '/update_all',     to: 'attendances#update_bunch'
  
  get '/attendance_in', to: 'attendances#attendance_in'
  

  resources :users do
    member do
      get :following, :followers
    end
  end
  
  resources :account_activations, only: [:edit]
  resources :password_resets,     only: [:new, :create, :edit, :update]
  resources :relationships,       only: [:create, :destroy]
  
end