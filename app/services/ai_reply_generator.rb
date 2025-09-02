class AiReplyGenerator
  def self.generate_for_diary(diary)
    # 既にAI返信がある場合は何もしない
    return if diary.has_ai_reply?

    begin
      gemini_service = GeminiService.new
      ai_response = gemini_service.generate_reply(diary)

      if ai_response.present?
        AiReply.create!(
          diary: diary,
          content: ai_response,
          replied_at: Time.current
        )
        Rails.logger.info "AI reply generated for diary ID: #{diary.id}"
      else
        Rails.logger.error "Failed to generate AI reply for diary ID: #{diary.id}"
      end
    rescue => e
      Rails.logger.error "Error generating AI reply for diary ID: #{diary.id} - #{e.message}"
    end
  end
end
