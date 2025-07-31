class Diary < ApplicationRecord
    mount_uploader :picture, PictureUploader

    # relation
    belongs_to :user
    has_many :comments, dependent: :destroy
end
