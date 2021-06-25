class V1::UserController < ApplicationController

  before_action :check_token, only: [:signout, :password, :add_friend, :solicitude, :delete_friend, :friend_list, :send_message, :load_messages]

  before_action :check_friend, only: [:add_friend, :solicitude, :delete_friend]

  before_action :check_enabled, only: [:add_friend, :solicitude, :delete_friend, :send_message]

  before_action :check_friend_to_chat, only: [:send_message, :load_messages]

  # este create lo pase aca desde users_controller.rb
  def create
    user = User.new(user_params)
    if user.save
      render(json: { token: user.generate_token! }, status: 200)
    else
      render(json: format_error(request.path, user.errors.full_messages), status: 401)
    end
  end

  def signin
    user = User.find_by(login: user_params[:login])

    if user.present? && user.valid_password?(user_params[:password])
      render(json: { token: user.generate_token! }, status: 200)
    else
      error = user.blank? ? 'Vieja no existe ese' : 'Vieja es cualquiera el password'
      render(json: format_error(request.path, error), status: 401)
    end
  end

  def signout
    if current_user.remove_token(header_token)
      render(status: 200)
    else
      render(json: format_error(request.path, current_user.errors.full_messages), status: 401)
    end
  end

  def password
    if current_user.valid_password?(params["currentPassword"])
      if current_user.update(password: params["newPassword"])
        render(status: 200)
      else
        render(json: format_error(request.path, current_user.errors.full_messages), status: 401)
      end
    else
      render(json: format_error(request.path, 'El currentPassword es cualquiera'), status: 401)
    end
  end

  # Nuevas funcionalidades
  def add_friend
    if current_user.send_solicitude(selected_friend)
      render(status: 200)
    else
      render(json: format_error(request.path, 'No es posible enviar la solicitud de amistad'), status: 401)
    end
  end

  def solicitude
    if current_user.evaluate_solicitude(selected_friend, friend_params[:option])
      render(status: 200)
    else
      render(json: format_error(request.path, 'No se pudo aceptar/rechazar la solicitud de amistad'), status: 401)
    end
  end

  def delete_friend
    if current_user.remove_friend(selected_friend)
      render(status: 200)
    else
      render(json: format_error(request.path, 'No se pudo eliminar el usuario elegido de sus amigos'), status: 401)
    end
  end

  def friend_list
    render(json: current_user.get_friend_list, status: 200)
  end

  def pending_solicitudes
    received_solicitudes_user_ids = UserFriend.where(friend_id: current_user.id, accepted: false).pluck(:user_id)
    json = User.where(id: received_solicitudes_user_ids)

    render(json: json, status: 200)
  end

  # chat
  def send_message
    if current_user.send_message(friend_to_chat, message_params[:content])
      render(status: 200)
    else
      render(json: format_error(request.path, 'No se pudo enviar el mensaje'), status: 401)
    end
  end

  def load_messages
    message_list = current_user.load_messages(friend_to_chat)
    render(json: message_list, status: 200)
  end

  private

  # agrego :name para usarlo en el create
  def user_params
    params.require(:user).permit(:name, :login, :password)
  end

  def friend_params
    params.require(:user).permit(:login, :option)
  end

  def check_friend
    return if selected_friend.present?

    render(json: format_error(request.path, 'No existe el usuario'), status: 401)
  end

  def selected_friend
    User.find_by(login: friend_params[:login])
  end

  def message_params
    params.require(:message).permit(:login, :content)
  end

  def friend_to_chat
    User.find_by(login: message_params[:login])
  end

  def check_friend_to_chat
    return if friend_to_chat.present?

    render(json: format_error(request.path, 'No existe el usuario'), status: 401)
  end




  # def friend_list
  #   user_friend_list_ids = UserFriend.where(user_id: current_user.id, accepted: true).pluck(:friend_id)
  #   user_friend_list_ids += UserFriend.where(friend_id: current_user.id, accepted: true).pluck(:user_id)
  #   json = User.where(id: user_friend_list).except(:password, :enable)

  #   # UserFriend.where("user_id = :user_id OR friend_id = :user_id", user_id: current_user.id).where(accepted: true)

  #   render(json: json, status: 200)
  # end
end
