require "rails_helper"

RSpec.describe Question, type: :model do
  describe "associations" do
    it { should belong_to(:test) }
    it { should have_many(:answers).dependent(:destroy) }
  end

  describe "validations" do
    let(:test) { create(:test) }
    let(:question) { build(:question, test: test) }

    context "when all fields are valid" do
      before do
        question.answers.build(content: "Answer 1", correct: true)
        question.answers.build(content: "Answer 2", correct: false)
      end

      it "is valid" do
        expect(question).to be_valid
      end
    end

    context "when content is present" do
      before do
        question.answers.build(content: "Answer 1", correct: true)
        question.content = "What is Ruby?"
      end

      it "is valid" do
        expect(question).to be_valid
      end
    end

    context "when content is blank" do
      before { question.content = "" }

      it "is invalid" do
        expect(question).not_to be_valid
      end

      it "has content blank error message" do
        question.valid?
        expect(question.errors[:content]).to include("can't be blank")
      end
    end

    context "when question_type is present" do
      before do
        question.answers.build(content: "Answer 1", correct: true)
        question.question_type = "single_choice"
      end

      it "is valid" do
        expect(question).to be_valid
      end
    end

    context "when question_type is blank" do
      before { question.question_type = nil }

      it "is invalid" do
        expect(question).not_to be_valid
      end

      it "has question_type blank error message" do
        question.valid?
        expect(question.errors[:question_type]).to include("can't be blank")
      end
    end

    context "when has at least one correct answer" do
      before do
        question.answers.build(content: "Correct Answer", correct: true)
        question.answers.build(content: "Wrong Answer", correct: false)
      end

      it "is valid" do
        expect(question).to be_valid
      end
    end

    context "when has no correct answers" do
      before do
        question.answers.clear
        question.answers.build(content: "Wrong Answer 1", correct: false)
        question.answers.build(content: "Wrong Answer 2", correct: false)
      end

      it "is invalid" do
        expect(question).not_to be_valid
      end

      it "has correct answer required error message" do
        question.valid?
        expect(question.errors[:base]).to include(I18n.t("admin.questions.at_least_one_correct_answer_required"))
      end
    end

    context "when has no answers" do
      before do
        question.answers.clear
      end

      it "is invalid" do
        expect(question).not_to be_valid
      end

      it "has correct answer required error message" do
        question.valid?
        expect(question.errors[:base]).to include(I18n.t("admin.questions.at_least_one_correct_answer_required"))
      end
    end
  end

  describe "enums" do
    it { should define_enum_for(:question_type).with_values(single_choice: 0, multiple_choice: 1) }
  end

  describe "nested attributes" do
    let(:question) { build(:question) }

    it "accepts nested attributes for answers" do
      expect(question).to respond_to(:answers_attributes=)
    end
  end

  describe "custom validations" do
    let(:test) { create(:test) }
    let(:question) { build(:question, test: test) }

    describe "#at_least_one_correct_answer" do
      context "when answers contain at least one correct answer" do
        before do
          allow(question.answers).to receive(:any?) { |&block| block.call(double(correct: true)) }
        end

        it "does not add validation error" do
          question.send(:at_least_one_correct_answer)
          expect(question.errors[:base]).to be_empty
        end
      end

      context "when answers contain no correct answers" do
        before do
          allow(question.answers).to receive(:any?) { |&block| block.call(double(correct: false)) }
        end

        it "adds validation error" do
          question.send(:at_least_one_correct_answer)
          expect(question.errors[:base]).to include(I18n.t("admin.questions.at_least_one_correct_answer_required"))
        end
      end
    end
  end
end
