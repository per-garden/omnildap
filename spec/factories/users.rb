FactoryBot.define do
  factory :user do
    sequence(:email) { Faker::Internet.email }
    password = Faker::Lorem.characters(9)
    password password
    password_confirmation password
    sequence(:name) { Faker::Internet.user_name }    
    backends []
    admin false
    blocked false

    factory :devise_user do
      backends [DeviseBackend.instance]

      factory :blocked_user do
        blocked true
      end

      factory :admin do
        admin true
      end
    end
  end

end
