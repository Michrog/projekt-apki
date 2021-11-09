json.profiles current_user.profiles do |profile|
  json.id profile.id
  json.name profile.name
  json.posts profile.posts do |post|
    json.id post.id
    json.title post.title
    json.profile_id post.profile.id
    json.content post.content
  end
end
