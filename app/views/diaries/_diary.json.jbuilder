json.extract! diary, :id, :title, :description, :picture, :published_at, :created_at, :updated_at
json.url diary_url(diary, format: :json)
