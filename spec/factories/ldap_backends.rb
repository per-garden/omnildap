FactoryGirl.define do
  factory :ldap_backend do
    name Faker::Lorem.word.capitalize
    host Faker::Lorem.word + '.' + Faker::Internet.domain_suffix
    port Rails.application.config.ldap_server[:port] + 1
    base 'ou=' + Faker::Commerce.department + ',dc=' + Faker::Commerce.product_name
    admin_name Faker::Internet.user_name
    admin_password Faker::Lorem.characters(9)
  end

end
