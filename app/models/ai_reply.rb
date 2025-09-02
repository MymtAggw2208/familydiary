class AiReply < ApplicationRecord
  belongs_to :diary

  validates :content, presence: true
end
