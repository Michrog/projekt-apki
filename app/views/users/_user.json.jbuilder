json.extract! user, :id, :name, :current_profile_id, :last_name, :user_type, :user_index, :created_at, :updated_at
json.url user_url(user, format: :json)
