FactoryGirl.define do
  factory :user do
    sequence(:email) { Faker::Internet.email }
    password = Faker::Lorem.characters(9)
    password password
    password_confirmation password
    name { Faker::Name.name }    
    backends [FactoryGirl.build(:ldap_backend)]
  end

end
