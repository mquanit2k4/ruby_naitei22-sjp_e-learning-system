require "rails_helper"

RSpec.describe Component, type: :model do
  describe "associations" do
    it { should belong_to(:lesson) }
    it { should belong_to(:test).optional }
    it { should belong_to(:word).optional }
    it { should have_many(:user_words).dependent(:destroy) }
    it { should have_many(:test_results).dependent(:destroy) }
  end

  describe "enums" do
    it { should define_enum_for(:component_type).with_values(word: 0, test: 1, paragraph: 2) }
  end

  describe "scopes" do
    let(:lesson) { create(:lesson) }
    let!(:component1) { create(:component, lesson: lesson, index_in_lesson: 3) }
    let!(:component2) { create(:component, lesson: lesson, index_in_lesson: 1) }
    let!(:component3) { create(:component, lesson: lesson, index_in_lesson: 2) }

    describe ".sorted_by_index" do
      it "orders components by index_in_lesson ascending" do
        expect(Component.sorted_by_index).to eq([component2, component3, component1])
      end
    end
  end

  describe "component types" do
    let(:lesson) { create(:lesson) }

    context "when component is word type" do
      let(:word) { create(:word) }
      let(:component) { create(:component, :word, lesson: lesson, word: word) }

      it "has word association" do
        expect(component.word).to eq(word)
      end

      it "has word component type" do
        expect(component.component_type).to eq("word")
      end
    end

    context "when component is test type" do
      let(:test) { create(:test) }
      let(:component) { create(:component, :test, lesson: lesson, test: test) }

      it "has test association" do
        expect(component.test).to eq(test)
      end

      it "has test component type" do
        expect(component.component_type).to eq("test")
      end
    end

    context "when component is paragraph type" do
      let(:component) { create(:component, :paragraph, lesson: lesson) }

      it "has paragraph component type" do
        expect(component.component_type).to eq("paragraph")
      end

      it "has no word association" do
        expect(component.word).to be_nil
      end

      it "has no test association" do
        expect(component.test).to be_nil
      end
    end
  end
end
