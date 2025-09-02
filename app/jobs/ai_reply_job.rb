class AiReplyJob < ApplicationJob
  queue_as :default

  def perform(diary_id)
    Rails.logger.info "🤖 AiReplyJob started for diary ID: #{diary_id}"

    diary = Diary.find_by(id: diary_id)
    unless diary
      Rails.logger.error "❌ Diary not found with ID: #{diary_id}"
      return
    end

    Rails.logger.info "📝 Processing diary: '#{diary.title}' by #{diary.user.name}"

    start_time = Time.current
    AiReplyGenerator.generate_for_diary(diary)
    end_time = Time.current

    Rails.logger.info "✅ AiReplyJob completed for diary ID: #{diary_id} in #{(end_time - start_time).round(2)}s"
  rescue => e
    Rails.logger.error "💥 AiReplyJob failed for diary ID: #{diary_id} - #{e.message}"
    raise e
  end
end
