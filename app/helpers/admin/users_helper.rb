module Admin::UsersHelper

  def member_of(gid)
    g = gid && Group.find(gid)
    g && g.users.include?(@user) 
  end

end
