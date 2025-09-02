require "httparty"

class GeminiService
  include HTTParty

  BASE_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent"

  def initialize
    @api_key = Rails.application.credentials.gemini_api_key || ENV["GEMINI_API_KEY"]
    raise "Gemini API key is missing" if @api_key.blank?
  end

  def generate_reply(diary)
    prompt = build_prompt(diary)

    response = Faraday.post("#{BASE_URL}?key=#{@api_key}") do |req|
      req.headers["Content-Type"] = "application/json"
      req.body = {
        contents: [ {
          parts: [ { text: prompt } ]
        } ],
        generationConfig: {
          temperature: 0.7,
          topK: 40,
          topP: 0.95,
          maxOutputTokens: 1024
        }
      }.to_json
    end

    if response.success?
      parsed_response = JSON.parse(response.body)
      content = parsed_response.dig("candidates", 0, "content", "parts", 0, "text")
      content&.strip
    else
      Rails.logger.error "Gemini API error: #{response.body}"
      "お疲れさまでした。素敵な日記をありがとうございます。"
    end
  rescue => e
    Rails.logger.error "Gemini API error: #{e.message}"
    "お疲れさまでした。素敵な日記をありがとうございます。"
  end

  private

  def build_prompt(diary)
    prompt = <<~TEXT
      あなたは投稿者にとって家族や友人のように親しみやすく、思い出を共有できるアシスタントです。
      以下の日記に対して、共感的かつ有効的なコメントを日本語で返してください。
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
end
