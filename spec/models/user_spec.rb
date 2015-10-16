require 'spec_helper'

describe User do
  it "has a valid factory" do
    expect(build :devise_user).to be_valid
  end

  it 'validates name' do
    user = FactoryGirl.build(:devise_user) 
    invalid_name = user.email
    user.name = invalid_name
    begin
      user.save!
    rescue
      # Expecting this to fail
    end
    # Expect not to be saved
    expect(user.id).to be nil
  end

  it 'validates email' do
    user = FactoryGirl.build(:devise_user) 
    invalid_email = user.email.gsub(/@/,'')
    user.email = invalid_email
    begin
      user.save!
    rescue
      # Expecting this to fail
    end
    # Expect not to be saved
    expect(user.id).to be nil
  end

  it 'belongs to a backend' do
    expect(build(:devise_user, backends: [])).not_to be_valid
  end
end
