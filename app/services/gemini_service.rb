require "gemini-ai"

class GeminiService
  def initialize
    @api_key = Rails.application.credentials.gemini_api_key || ENV["GEMINI_API_KEY"]
    raise "Gemini API key is missing" if @api_key.blank?

    @client = Gemini.new(
      credentials: {
        service: "generative-language-api",
        api_key: @api_key
      },
      options: {
        model: "gemini-2.0-flash",
        server_sent_events: false
      }
    )
  end

  def generate_reply(diary)
    prompt = build_prompt(diary)

    response = @client.stream_generate_content(
      {
        contents: {
          role: "user",
          parts: {
            text: prompt
          }
        },
        generationConfig: {
          temperature: 0.7,
          topK: 40,
          topP: 0.95,
          maxOutputTokens: 1024
        }
      }
    )

    # gemini-ai gemのレスポンス形式に対応
    content = extract_content_from_response(response)
    content&.strip
  rescue => e
    Rails.logger.error "Gemini API error: #{e.message}"
    "お疲れ様でした。素敵な日記をありがとうございます。"
  end

  private

  def build_prompt(diary)
    prompt = <<~TEXT
      あなたは投稿者にとって家族や友人のように親しみやすく、思い出を共有できるアシスタントです。
      以下の日記に対して、共感的かつ友好的なコメントを日本語で返してください。
      楽しい思い出には喜び、悲しい思い出には共感と励ましを添えてください。
      コメントは200文字前後で、適度に改行を入れてください。

      【日記情報】
      タイトル: #{diary.title}
      投稿者: #{diary.user.name}さん
      投稿日時: #{diary.published_at&.strftime('%Y年%m月%d日 %H:%M')}

      【日記内容】
      #{diary.description}
    TEXT

    prompt
  end

  def extract_content_from_response(response)
    # gemini-ai gemのレスポンス構造に対応
    # 配列の最初の要素から、candidates[0]['content']['parts'][0]['text'] を取得
    return nil if response.nil? || response.empty?

    # streamの場合、配列で複数のchunkが返される可能性があるので、全部結合
    text_parts = []

    response.each do |chunk|
      next unless chunk&.dig("candidates")

      chunk["candidates"].each do |candidate|
        content = candidate&.dig("content", "parts")
        next unless content

        content.each do |part|
          text_parts << part["text"] if part["text"]
        end
      end
    end

    text_parts.join
  rescue => e
    Rails.logger.error "Failed to extract content from response: #{e.message}"
    nil
  end
end
