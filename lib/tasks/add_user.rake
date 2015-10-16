# Run like: rake add_user 'name' 'email' 'password'

require 'rake'

# Using copy of input vector string to avoid "can't modify frozen String"
name = ARGV[1].dup if ARGV[1]
email = ARGV[2].dup if ARGV[2]
password = ARGV[3].dup if ARGV[3]
if !(name && email && password) && ARGV[0] == 'add_user'
  puts "Usage: rake add_user 'email' 'password' 'firstname' 'lastname' 'phone' 'partner'"
end

task :add_user => :environment do
  if password
    u = User.create(name: name, email: email, password: password, password_confirmation: password)
    u.backends << DeviseBackend.instance
    u.save!
    exit
  else
    abort
  end
end
