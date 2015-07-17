FactoryGirl.define do
  factory :user do
    sequence(:email) { Faker::Internet.email }
    password = Faker::Lorem.characters(9)
    password password
    password_confirmation password
    sequence(:name) { Faker::Internet.user_name }    
    backends [FactoryGirl.build(:devise_backend)]
    admin false
    blocked false

    factory :blocked_user do
      blocked true
    end

    factory :admin do
      admin true
    end
  end
end
