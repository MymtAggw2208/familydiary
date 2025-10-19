class DailyChatsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_daily_chat, only: [ :show, :clear_messages ]

  def show
    @chat_messages = @daily_chat.chat_messages.ordered.includes(:daily_chat)
    @new_message = ChatMessage.new

    # 初回アクセス時にAIからの挨拶メッセージを生成
    generate_initial_message if @daily_chat.needs_initial_message?

    # メッセージが追加された場合は再読み込み
    @chat_messages = @daily_chat.chat_messages.ordered.includes(:daily_chat)
  end

  def show_date
    date = Date.parse(params[:date])
    @daily_chat = current_user.daily_chats.for_date(current_user, date)
    @chat_messages = @daily_chat.chat_messages.ordered.includes(:daily_chat)
    @new_message = ChatMessage.new

    render :show
  rescue ArgumentError
    redirect_to today_daily_chats_path, alert: "無効な日付です。"
  end

  def history
    @daily_chats = current_user.daily_chats.ordered
                                .joins(:chat_messages)
                                .group(:id)
                                .having("COUNT(chat_messages.id) > 0")
                                .includes(:chat_messages)
                                .limit(30)
  end

  def clear_messages
    @daily_chat.chat_messages.destroy_all
    redirect_to today_daily_chats_path, notice: "今日のメッセージをクリアしました。"
  end

  private

  def set_daily_chat
    @daily_chat = current_user.daily_chats.for_today(current_user)
  end

  def generate_initial_message
    begin
      daily_chat_service = DailyChatService.new
      initial_message = daily_chat_service.generate_daily_greeting(@daily_chat, current_user)

      if initial_message.present?
        @daily_chat.chat_messages.create!(
          content: initial_message,
          role: "assistant"
        )
      end
    rescue => e
      Rails.logger.error "Initial message generation failed: #{e.message}"
      # フォールバック用のデフォルトメッセージ
      @daily_chat.chat_messages.create!(
        content: "おはようございます！今日は何をする予定ですか？",
        role: "assistant"
      )
    end
  end
end
