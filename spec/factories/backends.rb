FactoryGirl.define do

  factory :ldap_backend do
    name Faker::Lorem.word.capitalize
    host Rails.application.config.ldap_server[:host]
    port Rails.application.config.ldap_server[:port] + 1
    base 'ou=' + Faker::Commerce.department + ',dc=' + Faker::Commerce.product_name
    sequence(:admin_name) { Faker::Internet.user_name }
    admin_password Faker::Lorem.characters(9)
  end

  factory :active_directory_backend do
    name Faker::Company.name
    host Faker::Lorem.word + '.' + Faker::Internet.domain_suffix
    port Faker::Number.number(2)
    base 'ou=' + Faker::Commerce.department + ',dc=' + Faker::Commerce.product_name
    domain :host
  end

end
