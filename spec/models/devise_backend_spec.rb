require 'spec_helper'

describe DeviseBackend do
  it "has a valid factory" do
    expect(build :devise_backend).to be_valid
  end
end
