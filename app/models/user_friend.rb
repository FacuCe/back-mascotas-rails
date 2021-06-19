class UserFriend < ApplicationRecord
    belongs_to :user

    validates :user, :friend_id, presence: true

    def self.relationship_exists?(id_1, id_2)
        !UserFriend.where(user_id: id_1, friend_id: id_2).empty? || !UserFriend.where(user_id: id_2, friend_id: id_1).empty?
    end

    def self.confirmed_relationship?(id_1, id_2)
        !UserFriend.where(user_id: id_1, friend_id: id_2, accepted: true).empty? || !UserFriend.where(user_id: id_2, friend_id: id_1, accepted: true).empty?
    end
end
