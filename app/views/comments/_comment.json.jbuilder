json.extract! comment, :id, :content, :comment_date, :comment_time, :profile_id, :post_id, :created_at, :updated_at
json.url comment_url(comment, format: :json)
