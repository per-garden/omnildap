module Admin::GroupsHelper

  def member(uid)
    u = uid && User.find(uid)
    u && u.groups.include?(@group) 
  end

end
