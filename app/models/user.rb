class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         authentication_keys: [ :login_id ]

  # Validate
  validates :name, presence: true, length: { maximum: 20 }
  validates :login_id, presence: true, length: { maximum: 20 }, uniqueness: true

  # relation
  has_many :diaries, dependent: :destroy
  has_many :comments, dependent: :destroy

  enum :role, { test: "test", admin: "administrator" }

  # 認証キーをlogin_idに設定
  def self.find_for_authentication(warden_conditions)
    where(login_id: warden_conditions[:login_id]).first
  end

  # 仮想属性でrole_typeを定義
  def role_type
    role || "general"
  end

  # 権限種類の設定
  def role_type=(value)
    case value
    when "general"
      self.role = nil
    when "test", "administrator"
      self.role = value
    end
  end

  # 管理者ユーザー判定
  def administrator?
    admin?
  end

  # テストユーザー判定
  def test_user?
    test?
  end

  # 他のユーザーを編集可能かチェック
  def can_edit_user?(target_user)
    return true if administrator? # 管理者は全員編集可能
    return false if test_user? # テストユーザーは誰も編集不可
    return true if self == target_user # 一般ユーザーは自分のみ編集可能
    false
  end
end
