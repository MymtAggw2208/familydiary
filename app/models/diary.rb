class Diary < ApplicationRecord
    mount_uploader :picture, PictureUploader

    # relation
    belongs_to :user
    has_many :comments, dependent: :destroy
    has_one :ai_reply, dependent: :destroy

    # validation
    validates :title, presence: true
    validates :description, presence: true

    # AI返信の存在チェック
    def has_ai_reply?
        ai_reply.present?
    end
end
