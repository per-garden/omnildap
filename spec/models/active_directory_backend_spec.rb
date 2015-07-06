require 'spec_helper'

describe LdapBackend do
  it "has a valid factory" do
    expect(build :active_directory_backend).to be_valid
  end
end
