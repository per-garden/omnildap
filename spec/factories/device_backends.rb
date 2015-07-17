FactoryGirl.define do
  factory :devise_backend do
    sequence(:name) { Faker::Company.name }

    factory :blocked_backend do
      blocked true
    end
  end

end
