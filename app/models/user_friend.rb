class UserFriend < ApplicationRecord
    belongs_to :user
    has_many :messages

    validates :user, :friend_id, presence: true

    def self.relationship_exists?(id_1, id_2)
        UserFriend.where(user_id: id_1, friend_id: id_2).any? || UserFriend.where(user_id: id_2, friend_id: id_1).any?
    end

    def self.confirmed_relationship(id_1, id_2)
        UserFriend.where(user_id: id_1, friend_id: id_2, accepted: true).first || UserFriend.where(user_id: id_2, friend_id: id_1, accepted: true).first
    end


    
    # def self.search_by_ids(id_1, id_2)
    #     res = UserFriend.where(user_id: id_1, friend_id: id_2, accepted: true)
    #     return res.first if res.present?
    #     res = UserFriend.where(user_id: id_2, friend_id: id_1, accepted: true)
    #     return res.first if res.present?
    # end
end
