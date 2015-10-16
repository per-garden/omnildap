# Delete user.
# Run like: rake delete_user 'name'|'email'

require 'rake'

name_email = ARGV[1].dup if ARGV[1]
if !(name_email) && ARGV[0] == 'delete_user'
  puts "Usage: rake delete_user 'name|email'"
end

task :delete_user => :environment do
  if name_email
    u = User.find_by_name(name_email) || User.find_by_email(name_email)
    if u
      u.destroy!
      exit
    else
      abort
    end
  end
end
