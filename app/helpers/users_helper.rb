module UsersHelper

  def current_profile
    prof_id = current_user.current_profile_id
    @current_profile ||= Profile.find_by(id: prof_id)
  end

  def profile_set?
    !current_profile.nil?
  end

end
