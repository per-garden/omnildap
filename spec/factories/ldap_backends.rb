FactoryGirl.define do
  factory :ldap_backend do
    name Faker::Lorem.word.capitalize
    host Faker::Lorem.word + '.' + Faker::Internet.domain_suffix
    port Rails.application.config.ldap_server[:port] + 1
    base 'ou=' + Faker::Commerce.department + ',dc=' + Faker::Commerce.product_name
  end

end
