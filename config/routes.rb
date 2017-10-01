Rails.application.routes.draw do
  get 'dashboard/home'

  root to: 'dashboard#home'
  get 'settings', to: 'dashboard#settings', as: :settings
  post 'settings', to: 'dashboard#update_email_settings', as: :update_email_settings
  post 'update_password', to: 'dashboard#update_password', as: :update_password
  post 'logout_all', to: 'dashboard#logout_all_sessions', as: :logout_all

  get  'login', to: 'authentication#login_form', as: :login
  post 'login', to: 'authentication#login'

  get  'register', to: 'authentication#create_password_form'
  post 'register', to: 'authentication#create_password'

  get  'confirm', to: 'authentication#confirm_account_form'
  post 'confirm', to: 'authentication#confirm_account'

  get  'forgot', to: 'authentication#forgotten_password_form'
  post 'forgot', to: 'authentication#forgotten_password'

  get  'reset_password', to: 'authentication#reset_password_form'
  post 'reset_password', to: 'authentication#reset_password'

  get 'logout', to: 'authentication#logout_confirm'
  delete 'logout', to: 'authentication#logout'

  get 'people/mass_new', to: 'people#mass_new'
  post 'people/mass_new', to: 'people#mass_create'
  resources :people

  resources :groups do
    get 'invite', to: 'members#invite'
    post 'invite', to: 'members#process_invite'

    get 'mass_add', to: 'groups#mass_add_members'
    post 'mass_add', to: 'groups#process_mass_add_members'

    post 'subgroups', to: 'groups#create_default_subgroup', as: 'create_default_subgroup'
    patch 'subgroups/:default_subgroup_id', to: 'groups#update_default_subgroup', as: 'update_default_subgroup'
    delete 'subgroups(/:default_subgroup_id)', to: 'groups#destroy_default_subgroup', as: 'destroy_default_subgroup'

    resources :members do
      post 'promote', to: 'members#promote', on: :member
      post 'demote', to: 'members#demote', on: :member
    end

    get 'activities/mass_new', to: 'activities#mass_new'
    post 'activities/mass_new', to: 'activities#mass_create'

    resources :activities do
      post 'change_organizer', to: 'activities#change_organizer'
      put 'presence', to: 'activities#presence', on: :member
      patch 'presence', to: 'activities#presence', on: :member
    end
  end
  get 'my_groups', to: 'groups#user_groups', as: :user_groups

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  namespace 'api' do
    get 'status'
    scope 'me' do
      root to: 'me#index'
      get 'groups', to: 'me#groups'
    end

    resources :groups, only: [:index, :show]

    resources :activities, only: [:index, :show]
    get 'activities/:id/response_summary', to: 'activities#response_summary'

    resources :people, only: [:index, :show]
  end
end
