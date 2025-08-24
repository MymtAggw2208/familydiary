Rails.application.routes.draw do
  # Deviseのregistrationsコントローラーをカスタムコントローラーで上書き
  devise_for :users, controllers: {
    registrations: "users/registrations"
  }

  # 管理者が他のユーザーの情報を編集するためのルート
  devise_scope :user do
    get "/users/:id/edit", to: "users/registrations#edit", as: "edit_other_user_registration"
    patch "/users/:id", to: "users/registrations#update", as: "update_other_user_registration"
    delete "/users/:id", to: "users/registrations#destroy", as: "delete_other_user_registration"
  end

  # ユーザー一覧・詳細表示用
  resources :users, only: [ :index, :show ]

  root to: redirect("/diaries")
  resources :diaries do
    resources :comments, only: [ :create, :destroy ]
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
