require 'spec_helper'

describe User do
  it "has a valid factory" do
    expect(build :user).to be_valid
  end

  it 'belongs to a backend' do
    expect(build(:user, backends: [])).not_to be_valid
  end
end
