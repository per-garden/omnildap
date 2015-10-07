require 'spec_helper'

describe Group do
  it "has a valid factory" do
    expect(build :group).to be_valid
  end

end
