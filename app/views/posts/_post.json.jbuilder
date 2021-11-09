json.extract! post, :id, :content, :post_date, :post_group, :title, :profile_id, :created_at, :updated_at
json.url post_url(post, format: :json)
