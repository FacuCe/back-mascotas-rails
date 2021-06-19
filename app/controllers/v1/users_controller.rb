class V1::UsersController < ApplicationController
  before_action :check_token,
    only: [
      :index,
      :grant,
      :current,
      :revoke,
      :enable,
      :disable
    ]
  
  before_action :verify_admin_or_god,
    only: [
      :index
    ]

  before_action :verify_selected_client,
    only: [
      :grant,
      :revoke,
      :enable,
      :disable
    ]
  
  before_action :verify_permission,
    only: [
      :enable,
      :disable,
      :grant,
      :revoke
    ]

  def index
    render(json: User.all.map(&:json), status: 200)
  end

  def grant
    params["permissions"].each do |perm|
      selected_user.add_role(perm) if grant_roles_permitted?(perm)
    end
    render(status: 200)
  end

  def revoke
    params["permissions"].each do |perm|
      selected_user.remove_role(perm) if revoke_roles_permitted?(perm)
    end
    render(status: 200)
  end

  def enable
    selected_user.update(enabled: true)
    render(status: 200)
  end

  def disable
    selected_user.update(enabled: false)
    render(status: 200)
  end

  def current
    json = current_user.json
    json.delete(:enabled)

    render(json: json, status: 200)
  end
end
