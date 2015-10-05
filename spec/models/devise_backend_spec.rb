require 'spec_helper'

describe 'DeviseBackend' do
  it "has a valid factory" do
    expect(DeviseBackend.instance).to be_valid
  end

  it "is a singleton" do
    b = DeviseBackend.instance
    expect(DeviseBackend.instance).to eql(b)
  end
end
