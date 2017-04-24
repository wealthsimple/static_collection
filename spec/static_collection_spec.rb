require "spec_helper"

RSpec.describe StaticCollection do
  it "has a version number" do
    expect(StaticCollection::VERSION).not_to be nil
  end

  it "does something useful" do
    expect(false).to eq(true)
  end
end
