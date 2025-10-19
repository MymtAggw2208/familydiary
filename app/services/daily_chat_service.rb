class DailyChatService
  def initialize
    @gemini_service = GeminiService.new
  end

  def generate_daily_greeting(daily_chat, current_user)
    # 今日の日付情報を取得
    today = daily_chat.chat_date
    day_info = get_day_information(today)

    # 曜日と時間帯に応じた挨拶
    greeting_prompt = build_greeting_prompt(today, day_info, current_user)

    # Gemini APIを呼び出し
    response = @gemini_service.generate_chat_response(greeting_prompt)

    response
  end

  def generate_response(daily_chat, user_message)
    # チャット履歴を構築
    conversation_history = build_conversation_history(daily_chat)

    # システムプロンプトを設定
    system_prompt = build_system_prompt(daily_chat)

    # 最終的なプロンプトを構築
    full_prompt = build_full_prompt(system_prompt, conversation_history, user_message)

    # Gemini APIを呼び出し
    response = @gemini_service.generate_chat_response(full_prompt)

    response
  end

  private

  def get_day_information(date)
    day_info = {
      date: date,
      weekday: %w[日 月 火 水 木 金 土][date.wday],
      is_weekend: date.saturday? || date.sunday?,
      season: get_season(date),
      month_day: date.strftime("%m月%d日")
    }

    day_info
  end

  def get_season(date)
    case date.month
    when 3, 4, 5
      "春"
    when 6, 7, 8
      "夏"
    when 9, 10, 11
      "秋"
    else
      "冬"
    end
  end

  def build_greeting_prompt(date, day_info, current_user)
    current_hour = Time.current.hour
    current_minute = Time.current.min
    time_greeting = case current_hour
    when 5..11
                     "おはようございます"
    when 12..17
                     "こんにちは"
    else
                     "こんばんは"
    end

    user_name = current_user.name.encode("UTF-8", invalid: :replace, undef: :replace)
    age = current_user.birthday ? ((Date.current - current_user.birthday).to_i / 365).to_s + "歳です。" : "わかりません。"
    family_info = current_user.family ? current_user.family.encode("UTF-8", invalid: :replace, undef: :replace) + "との" : ""

    <<~TEXT
      あなたは親しみやすく、ユーザーの日常を応援するAIアシスタントです。
      今日（#{day_info[:month_day]}・#{day_info[:weekday]}曜日・#{current_hour}時#{current_minute}分）の
      #{day_info[:season]}の日に、ユーザーと「今日何をする？」というテーマで対話を始めます。

      以下の条件で挨拶メッセージを生成してください：

      ・#{time_greeting}の挨拶から始めましょう
      ・今日の日付や曜日、季節を自然に織り込んでください。
      ・https://ja.wikipedia.org/wiki/#{day_info[:month_day]}の記念日や出来事を参考にしてください。
      ・記念日や出来事から連想する場合、なるべく時代が近く手ごろな話題にしましょう。
      　例：9月23日なら「ビスマルクがプロイセン首相に就任した日ですね。ドイツの歴史を調べてみませんか？」ではなく、「秋分の日ですね。秋の味覚を楽しむのはどうでしょう？」等
      ・ユーザーは#{user_name}さん、年齢は#{age}
      ・応答にユーザーの名前は使って構いませんが、年齢は使わないでください。
      ・ユーザーが20歳以上なら#{family_info}思い出を尋ねてください。
      　例：ユーザーが30歳で家族が「母」かつ9月23日なら、「今日は秋分の日ですね。小さいころはお母さんとおはぎを食べたりしたでしょうか？」等
      　　　ユーザーが30歳で家族がわからない場合、「今日は秋分の日ですね。小さいころにした秋ならではの遊びはありますか？」等
      ・ユーザーが20歳未満もしくは年齢がわからない場合、#{family_info}今日の予定を尋ねてください。
      　例：ユーザーが19歳で家族が「父」かつ9月23日なら、「今日は秋分の日ですね。お父さんと一緒にどこかに出かけませんか？」等
      　　　ユーザーが19歳で家族がわからない場合、「今日は秋分の日ですね。あなたにとって秋らしい楽しみといえば何ですか？」等
      ・親しみやすく、前向きな雰囲気で会話しましょう
      ・現在時刻が19時以降の場合、今日の予定ではなく振り返りを促してください
      　例：9月23日なら「今日は秋分の日でしたね。秋を感じる出来事はありましたか？」10月3日でユーザーが20歳以上、家族情報が母なら「今日は国産みその日でしたね。お母さんとお味噌汁を飲みましたか？」等
      ・現在時刻が19時より前の場合、#{day_info[:is_weekend] ? '比較的時間をかけてリラックスした活動や趣味' : '昼休みや夜のちょっとした時間にできるリフレッシュ'}を提案してください
      ・100文字程度で簡潔にまとめましょう
    TEXT
  end

  def build_conversation_history(daily_chat)
    # 当日のメッセージ履歴を取得
    messages = daily_chat.chat_messages.ordered

    history = []
    messages.each do |message|
      role = message.user_message? ? "ユーザー" : "アシスタント"
      history << "#{role}: #{message.content}"
    end

    history.join("\n")
  end

  def build_system_prompt(daily_chat)
    day_info = get_day_information(daily_chat.chat_date)

    <<~TEXT
      あなたは親しみやすく知識豊富なAIアシスタントです。
      今日（#{day_info[:month_day]}・#{day_info[:weekday]}曜日）の#{day_info[:season]}の日に、
      「今日何をする？」というテーマでユーザーと対話しています。

      対話のガイドライン：
      ・親しみやすく丁寧な口調で話してください
      ・ユーザーの今日の予定や気持ちに寄り添った回答を心がけてください
      ・家族との時間や思い出作りも大切にした提案をしてください
      ・ユーザーが提案に乗り気であれば、さらに具体的なアクションを提案してください
      　例：料理を提案した場合、「何を作るか考えてみましょう。使いたい食材はありますか？」等
      ・ユーザーが提案に乗り気でない場合は、実現可能性を高めるようなささやかな提案をしてください
      　例：運動を提案した場合、「YouTubeを見ながら、5分だけストレッチしてみるのはどうですか？」等
      ・ユーザーが会話を切り上げたいと感じたら、見送るような言葉で締めくくってください
      ・回答は100-200文字程度に収めてください
    TEXT
  end

  def build_full_prompt(system_prompt, conversation_history, user_message)
    prompt = system_prompt

    if conversation_history.present?
      prompt += "\n\n【今日の対話履歴】\n#{conversation_history}"
    end

    prompt += "\n\n【ユーザーの最新メッセージ】\n#{user_message}"
    prompt += "\n\n上記を踏まえて、今日の活動に関する適切な返答をしてください："

    prompt
  end
end
