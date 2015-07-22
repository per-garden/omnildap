require 'spec_helper'

# Specs in this file have access to a helper object that includes
# the BackendsHelper. For example:
#
# describe BackendsHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
describe BackendsHelper do
  before do
    @devise_backend = FactoryGirl.build(:devise_backend)
    @devise_backend.save!
    @nameless_backend = FactoryGirl.build(:devise_backend, name: nil)
    @nameless_backend.save!
    @nameless_backend1 = FactoryGirl.build(:devise_backend, name: '')
  end

  it 'lists backends' do
    expect(helper.backend_all).to include(@devise_backend)
  end

  it 'returns name of named backend' do
    expect(helper.name(@devise_backend)).to be == @devise_backend.name
  end

  it 'returns id as name if no name set' do
    expect(helper.name(@nameless_backend)).to be == @nameless_backend.id.to_s
    expect(helper.name(@nameless_backend1)).to be == @nameless_backend1.id.to_s
  end

  after do
    @devise_backend.destroy
    @nameless_backend.destroy
  end
end
