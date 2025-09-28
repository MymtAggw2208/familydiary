class DailyChat < ApplicationRecord
  belongs_to :user
  has_many :chat_messages, dependent: :destroy

  validates :chat_date, presence: true
  validates :user_id, uniqueness: { scope: :chat_date }  # 1ユーザーごとに1日1回まで

  scope :ordered, -> { order(chat_date: :desc) }

  def self.for_today(user)
    find_or_create_by(user: user, chat_date: Date.current)
  end

  def self.for_date(user, date)
    find_or_create_by(user: user, chat_date: date)
  end

  def title
    if chat_date == Date.current
      "今日のチャット"
    else
      "#{chat_date.strftime('%Y年%-m月%-d日')}のチャット"
    end
  end

  def needs_initial_message?
    chat_messages.where(role: "assistant").empty?
  end

  def last_message
    chat_messages.last
  end
end
