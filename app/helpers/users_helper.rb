module UsersHelper

  def current_profile
    if logged_in?
      prof_id = current_user.current_profile_id
      @current_profile ||= Profile.find_by(id: prof_id)
    end
  end

  def profile_set?
    !current_profile.nil?
  end

end
