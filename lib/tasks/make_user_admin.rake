# Run like: rake make_user_admin 'name'|'email'

require 'rake'

# Using copy of input vector string to avoid "can't modify frozen String"
name_email = ARGV[1].dup if ARGV[1]

if !(name_email) && ARGV[0] == 'make_user_admin'
  puts "Usage: rake make_user_admin 'name|email'"
end

task :make_user_admin => :environment do
  u = User.find_by_name(name_email) || User.find_by_email(name_email)
  if u
    u.admin = true
    u.save!
    exit
  else
    abort
  end
end
