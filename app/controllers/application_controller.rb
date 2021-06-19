class ApplicationController < ActionController::API

  private

  def verify_selected_client
    # tengo que verificar que el usuario seleccionado no sea igual al current user
    return if selected_user.present? && selected_user.id != current_user.id

    if !selected_user.present?
      render(json: format_error(request.path, 'No existe el cliente'), status: 401)
    else
      render(json: format_error(request.path, 'El cliente sos vos'), status: 401)
    end
  end

  # verifico si el current user tiene permisos para el action
  def verify_permission
    return if action_permitted?

    render(json: format_error(request.path, 'Permiso denegado'), status: 401)
  end

  def action_permitted?
    @action_permitted ||= !selected_user.god? && (current_user.god? || (current_user.admin? && !selected_user.admin?))
  end

  # cual rol puedo otorgar
  def grant_roles_permitted?(role)
    grant_roles_permitted.include?(role)
  end

  def grant_roles_permitted
    @grant_roles_permitted ||= ['user', 'admin'] if (current_user.god? || current_user.admin?)
  end

  # cual rol puedo revocar
  def revoke_roles_permitted?(role)
    revoke_roles_permitted.include?(role)
  end

  def revoke_roles_permitted
    @revoke_roles_permitted ||= ['admin'] if current_user.god? && selected_user.admin?
  end

  # verifico permiso de god o admin
  def verify_admin_or_god
    return if current_user.admin? || current_user.god?

    render(json: format_error(request.path, "No tenes permiso"), status: 401)
  end

  # tengo que estar habilitado para interactuar con las mascotas
  def check_enabled
    return if current_user.enabled

    render(json: format_error(request.path, "Estas inhabilitado"), status: 401)
  end

  def check_token
    return if current_user.present?

    render(json: format_error(request.path, 'No se quien sos'), status: 401)
  end

  def format_error(path, message)
    { message: [{ path: path, message: message }] }
  end

  def header_token
    request.headers["Authorization"].split(" ").last
  end

  def current_user
    @current_user ||= User.find_by_token(header_token)
  end

  def selected_user
    @select_user ||= User.find_by(id: params[:id])
  end
end
