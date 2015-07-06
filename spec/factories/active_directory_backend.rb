FactoryGirl.define do
  factory :active_directory_backend do
    name Faker::Company.name
    host Faker::Lorem.word + '.' + Faker::Internet.domain_suffix
    port Faker::Number.number(2)
    base 'ou=' + Faker::Commerce.department + ',dc=' + Faker::Commerce.product_name
  end

end
