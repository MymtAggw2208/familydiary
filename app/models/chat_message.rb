class ChatMessage < ApplicationRecord
  belongs_to :daily_chat

  validates :content, presence: true
  validates :role, presence: true, inclusion: { in: %w[user assistant] }

  scope :ordered, -> { order(:created_at) }

  def user_message?
    role == "user"
  end

  def assistant_message?
    role == "assistant"
  end
end
