FactoryGirl.define do
  factory :user do
    sequence(:email) { Faker::Internet.email }
    password = Faker::Lorem.characters(9)
    password password
    password_confirmation password
    sequence(:name) { Faker::Internet.user_name }    
    backends [FactoryGirl.build(:devise_backend)]
    admin false

    factory :admin do
      admin true
    end

    factory :ldap_backend_user do
      backends [FactoryGirl.build(:ldap_backend)]
    end
  end
end
