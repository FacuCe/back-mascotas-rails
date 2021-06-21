# POST /v1/user => registrar usuario
# POST /v1/user/signin => login
# GET  /v1/user/signout => logout
# POST /v1/user/password => Cambiar password

# GET  /v1/users => Listar usuarios
# GET  /v1/users/current => Get user
# POST /v1/users/:userId/disable
# POST /v1/users/:userId/enable
# POST /v1/users/:userId/grant => Otorgar permisos
# POST /v1/users/:userId/revoke => Revocar permisos


# tp2

# Funcionalidad 1
# Un usuario habilitado significa que puede usar la funcionalidad de mascotas
# Un usuario con permiso de admin puede habilitar o deshabilitar usuarios con permiso user, pero no con permiso admin
# Un usuario con permiso de god puede revocar permiso de un admin
# Si soy admin puedo listar usuarios, luego habilitarlos o deshabilitarlos, dar o revocar permisos
# GET /v1/user

# Funcionalidad 2
# Un usuario puede agregar amigos
# Un usuario puede enviar mensajes a sus amigos (falta todo)


Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  namespace :v1, default: { format: :json } do
    resources :user, only: [:create] do
      collection do
        post :password
        post :signin
        get :signout
        # Funcionalidades nuevas
        post :add_friend
        post :solicitude
        post :delete_friend
        get :friend_list
        get :pending_solicitudes
      end
    end

    resources :users, only: [:index] do
      member do
        post :disable # Deshabilitar usuario
        post :enable # Habilitar usuario
        post :grant
        post :revoke
      end
      collection do
        get :current
      end
    end

    resources :pet, except: [:update] do
      member do
        post :update
      end
    end

    resources :image, only: [:create, :show]

    resources :profile, only: [:create] do
      collection do
        post :picture
      end
    end

    resources :province, only: [:index]
  end

  get '/v1/profile', controller: 'v1/profile', action: :show
end
