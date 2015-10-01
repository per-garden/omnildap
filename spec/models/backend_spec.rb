require 'spec_helper'

describe User do
  it "has a valid factory" do
    expect(DeviseBackend.instance).to be_valid
    expect(build :ldap_backend).to be_valid
    expect(build :active_directory_backend).to be_valid
  end
end
