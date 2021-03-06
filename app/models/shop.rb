# frozen_string_literal: true

class Shop < ApplicationRecord
  belongs_to :user
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :notifications, dependent: :destroy

  geocoded_by :address
  after_validation :geocode

  mount_uploader :image, ImageUploader

  def like_user(user_id)
    likes.find_by(user_id: user_id)
  end

  validates :name, presence: true
  validates :text, presence: true

  include JpPrefecture
  jp_prefecture :prefecture_code

  enum wifi: { yes: 1, no: 2 }
  enum power: { able: 1, unable: 2 }

  def create_notification_like!(current_user)
    temp = Notification.where(['visitor_id = ? and visited_id = ? and shop_id = ? and action = ? ', current_user.id, user_id, id, 'like'])
    return if temp.present?

    notification = current_user.active_notifications.new(
      shop_id: id,
      visited_id: user_id,
      action: 'like'
    )
    notification.checked = true if notification.visitor_id == notification.visited_id
    notification.save if notification.valid?
  end

  def create_notification_comment!(current_user, comment_id)
    temp_ids = Comment.select(:user_id).where(shop_id: id).where.not(user_id: current_user.id).distinct
    temp_ids.each do |temp_id|
      save_notification_comment!(current_user, comment_id, temp_id['user_id'])
    end
    save_notification_comment!(current_user, comment_id, user_id) if temp_ids.blank?
  end

  def save_notification_comment!(current_user, comment_id, visited_id)
    notification = current_user.active_notifications.new(
      shop_id: id,
      comment_id: comment_id,
      visited_id: visited_id,
      action: 'comment'
    )
    notification.save if notification.valid?
  end
end
