require 'spec_helper'

describe 'DeviseBackend' do
  it "is a singleton" do
    b = DeviseBackend.instance
    expect(DeviseBackend.instance).to eql(b)
  end
end
