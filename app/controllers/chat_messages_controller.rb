class ChatMessagesController < ApplicationController
  before_action :authenticate_user!

  def create
    @daily_chat = current_user.daily_chats.for_today(current_user)
    @user_message = @daily_chat.chat_messages.build(message_params.merge(role: "user"))

    if @user_message.save
      # AIからの返信を生成
      generate_ai_response
      redirect_to daily_chat_path(@daily_chat)
    else
      @chat_messages = @daily_chat.chat_messages.ordered
      @new_message = @user_message
      render "daily_chats/show", status: :unprocessable_entity
    end
  end

  private

  def message_params
    params.require(:chat_message).permit(:content)
  end

  def generate_ai_response
    begin
      daily_chat_service = DailyChatService.new
      ai_response = daily_chat_service.generate_response(@daily_chat, @user_message.content)

      if ai_response.present?
        @daily_chat.chat_messages.create!(
          content: ai_response,
          role: "assistant"
        )
      end
    rescue => e
      Rails.logger.error "AI response generation failed: #{e.message}"
      @daily_chat.chat_messages.create!(
        content: "申し訳ありませんが、現在返信を生成できません。しばらく後に再度お試しください。",
        role: "assistant"
      )
    end
  end
end
