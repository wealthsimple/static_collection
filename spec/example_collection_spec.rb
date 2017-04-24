require "yaml"

class ExampleCollection < StaticCollection::Base
  set_source YAML.load_file("./spec/fixtures/us_states.yml")
end

describe ExampleCollection do
  describe ".find_by_{attribute}" do
    it "returns a single record corresponding to the query" do
      maine = described_class.find_by_code("ME")
      expect(maine).to be_present
      expect(maine.code).to eq("ME")
      expect(maine.name).to eq("Maine")
    end

    it "returns nil if not found" do
      invalid = described_class.find_by_code("INVALID")
      expect(invalid).to be_nil
    end
  end

  describe ".count" do
    subject { described_class.count }

    it { is_expected.to eq(50) }
  end

  describe ".size" do
    subject { described_class.size }

    it { is_expected.to eq(50) }
  end
end
