require 'spec_helper'

describe LdapBackend do
  it "has a valid factory" do
    expect(build :ldap_backend).to be_valid
  end
end
