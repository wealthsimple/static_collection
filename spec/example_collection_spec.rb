require "yaml"

class ExampleCollection < StaticCollection::Base
  set_source YAML.load_file("./spec/fixtures/us_states.yml"), defaults: {contiguous: true}
end

describe ExampleCollection do
  describe ".find_by_{attribute}" do
    context "Maine" do
      it "returns a single record corresponding to the query" do
        maine = described_class.find_by_code("ME")
        expect(maine).to be_present
        expect(maine.code).to eq("ME")
        expect(maine.name).to eq("Maine")
        expect(maine).to be_contiguous
      end
    end

    context "Hawaii" do
      it "returns a single record corresponding to the query" do
        hawaii = described_class.find_by_code("HI")
        expect(hawaii).to be_present
        expect(hawaii.code).to eq("HI")
        expect(hawaii.name).to eq("Hawaii")
        expect(hawaii).not_to be_contiguous
      end
    end

    context "invalid query" do
      it "returns nil" do
        invalid = described_class.find_by_code("INVALID")
        expect(invalid).to be_nil
      end
    end
  end

  describe ".find_all_by_{attribute}" do
    context "with a valid query" do
      it "returns all matching records" do
        non_contiguous_states = described_class.find_all_by_contiguous(false)
        expect(non_contiguous_states).to be_a(Array)
        expect(non_contiguous_states.map(&:name)).to eq(["Alaska", "Hawaii"])
      end
    end

    context "with an invalid query" do
      it "returns empty array" do
        invalid = described_class.find_all_by_code("INVALID")
        expect(invalid).to eq([])
      end
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

  describe ".all" do
    it "returns all objects in the StaticCollection" do
      all_states = described_class.all
      expect(all_states).to be_a(Array)
      expect(all_states.first.name).to eq("Alabama")
    end
  end

  describe "#as_json" do
    subject { described_class.find_by_code("ME").as_json }

    it { is_expected.to eq({"code" => "ME", "name" => "Maine", "contiguous" => true}) }
  end
end
