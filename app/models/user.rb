class User < ApplicationRecord
  has_one :profile

  has_many :permissions
  has_many :pets

  #friends
  has_many :user_friends

  validates :name, :login, :password, presence: true

  validates :login, uniqueness: true

  validates :password, length: { minimum: 7 }

  scope :enabled, -> { where(enabled: true) }

  after_create do
    add_role('user')
    Profile.create!(user: self)
  end

  def valid_password?(pass)
    password.present? && password == pass
  end

  def generate_token!
    # Token persistente
    
    # Token con expiracion
    # client_redis.set("session_#{user.id}", token, ex: (60 * 60))
    token = SecureRandom.urlsafe_base64 

    $client_redis.set("session_#{token}", id)

    token
  end

  def remove_token(token)
    $client_redis.del("session_#{token}")
  end

  def add_role(new_role)
    role = Role.find_by(name: new_role) if new_role.instance_of?(String)

    raise "No existe lo que pasaste" if role.blank?

    # si el usuario no tenia este rol, entonces lo agrego
    if !role_names.include?(new_role)
      Permission.create!(user: self, role: role)
    end
  end

  def remove_role(role)
    role = Role.find_by(name: role) if role.instance_of?(String)

    raise "No existe lo que pasaste" if role.blank?

    permissions.where(role_id: role.id).each(&:destroy)
  end

  def admin?
    role_names.include?('admin')
  end

  def god?
    role_names.include?('god')
  end

  def role_names
    permissions.includes(:role).pluck("roles.name")
  end

  def json
    { id: id, name: name, login: login, enabled: enabled, permissions: role_names }
  end

  def self.find_by_token(htoken)
    id = $client_redis.get("session_#{htoken}")

    User.find_by(id: id)
  end

  # enviar solicitud de amistad
  def send_solicitude(friend)
    # verificar que friend.id no esté en un registro que contenga mi id y su id, tanto en user_id como en friend_id
    return false if id == friend.id || UserFriend.relationship_exists?(id, friend.id)
    
    new_user_friend = UserFriend.new(user: self, friend_id: friend.id)
    return new_user_friend.save
  end

  # aceptar o rechazar solicitud de amistad
  def evaluate_solicitude(friend, selected_option)
    user_friend = UserFriend.where(user_id: friend.id, friend_id: id, accepted: false).first

    return false if user_friend.blank?
    
    # selected_option == true --> aceptar solicitud
    if selected_option
      user_friend.accepted = true
      return user_friend.save
    else
      return user_friend.destroy.present?
    end
  end

  # eliminar amigo
  def remove_friend(friend)
    return false if my_friend(friend).blank?
    return my_friend(friend).destroy.present?
  end

  # buscar relacion de amigos entre usuarios
  def my_friend(friend)
    @my_friend ||= UserFriend.confirmed_relationship(id, friend.id)
  end

  # lista de amigos
  def get_friend_list
    user_friend_list_ids = UserFriend.where(user_id: id, accepted: true).pluck(:friend_id)
    user_friend_list_ids += UserFriend.where(friend_id: id, accepted: true).pluck(:user_id)
    User.where(id: user_friend_list_ids)
  end

  # enviar mensaje
  def send_message(friend, content)
    return false if my_friend(friend).blank?

    message = Message.new(content: content, user_friend: @my_friend, from: name)
    message.save
  end

  # actualizar chat
  def load_messages(friend)
    return if my_friend(friend).blank?
    @my_friend.messages
  end





  # lista de amigos (2da opcion)
  # def get_friend_list
  #   user_friends_list_ids = UserFriend.where("user_id = :user_id OR friend_id = :user_id", user_id: id).where(accepted: true).pluck(:friend_id, :user_id)
  #   User.where(id: user_friends_list_ids)
  # end

  # solicitudes enviadas pendientes
  # def pending_sended_solicitudes
  #   pending_friends_id = UserFriend.where(user_id: id, accepted: false).pluck(:friend_id)
  #   pending_friends_id.map do |f_id|
  #     User.find_by(id: f_id)
  #   end
  # end

  # solicitudes recibidas pendientes
  # def pending_received_solicitude(friend)
  #   UserFriend.where(user_id: friend.id, friend_id: id, accepted: false).first
  # end

  # def user_who_sent_me_a_solicitude(friend_id)
  #   if UserFriend.where(user_id: friend_id, friend_id: id, accepted: false).any?
  #     User.find_by(id: friend_id)
  #   end
  # end

  # buscar amigo
  # def search_friend(friend)
  #   return User.find_by(id: friend_id) if (is_my_friend?(friend))
  # end
end
