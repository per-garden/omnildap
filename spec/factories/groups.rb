FactoryGirl.define do
  factory :group do
    sequence(:name) { Faker::Commerce.department }    
    users []
  end

end
