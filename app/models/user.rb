class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         authentication_keys: [:login_id]

  # Validate
  validates :name, presence: true, length: { maximum: 20 }
  validates :login_id, presence: true, length: {maximum: 20}, uniqueness: true

  # relation
  has_many :diaries, dependent: :destroy
  has_many :comments, dependent: :destroy

  # 認証キーをlogin_idに設定
  def self.find_for_authentication(warden_conditions)
    where(login_id: warden_conditions[:login_id]).first
  end
end
