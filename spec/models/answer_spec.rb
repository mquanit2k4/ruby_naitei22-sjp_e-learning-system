require "rails_helper"

RSpec.describe Answer, type: :model do
  describe "associations" do
    it { should belong_to(:question) }
  end

  describe "validations" do
    let(:answer) { build(:answer) }

    context "when all fields are valid" do
      it "is valid" do
        expect(answer).to be_valid
      end
    end

    context "when content is present" do
      before { answer.content = "Valid answer content" }

      it "is valid" do
        expect(answer).to be_valid
      end
    end

    context "when content is blank" do
      before { answer.content = "" }

      it "is invalid" do
        expect(answer).not_to be_valid
      end

      it "has content blank error message" do
        answer.valid?
        expect(answer.errors[:content]).to include("can't be blank")
      end
    end
  end

  describe "callbacks" do
    describe "after_initialize" do
      context "when creating new record" do
        context "and correct is nil" do
          let(:answer) { Answer.new }

          it "sets correct to false" do
            expect(answer.correct).to be false
          end
        end

        context "and correct is already set" do
          let(:answer) { Answer.new(correct: true) }

          it "does not change correct value" do
            expect(answer.correct).to be true
          end
        end
      end

      context "when loading existing record" do
        let!(:saved_answer) { create(:answer, correct: true) }

        it "does not modify correct value" do
          loaded_answer = Answer.find(saved_answer.id)
          expect(loaded_answer.correct).to be true
        end
      end
    end
  end

  describe "default values" do
    context "when creating new answer without correct value" do
      let(:answer) { Answer.new(content: "Test answer") }

      it "defaults correct to false" do
        expect(answer.correct).to be false
      end
    end

    context "when creating new answer with correct value" do
      let(:answer) { Answer.new(content: "Test answer", correct: true) }

      it "preserves the specified correct value" do
        expect(answer.correct).to be true
      end
    end
  end
end
