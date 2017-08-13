require "spec_helper"

RSpec.describe SimpleJSONAPIClient do
  it "has a version number" do
    expect(SimpleJSONAPIClient::VERSION).not_to be nil
  end
end
