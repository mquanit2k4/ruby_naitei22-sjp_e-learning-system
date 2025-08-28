require "rails_helper"

RSpec.describe Lesson, type: :model do
  describe "associations" do
    it { should belong_to(:course) }
    it { should belong_to(:creator).class_name("User").with_foreign_key("created_by_id") }
    it { should have_many(:components).dependent(:destroy) }
    it { should have_many(:user_lessons).dependent(:destroy) }
  end

  describe "validations" do
    let(:lesson) { build(:lesson) }

    context "when all fields are valid" do
      it "is valid" do
        expect(lesson).to be_valid
      end
    end

    context "when title is present" do
      before { lesson.title = "Valid Lesson Title" }

      it "is valid" do
        expect(lesson).to be_valid
      end
    end

    context "when title is blank" do
      before { lesson.title = "" }

      it "is invalid" do
        expect(lesson).not_to be_valid
      end

      it "has title blank error message" do
        lesson.valid?
        expect(lesson.errors[:title]).to include("can't be blank")
      end
    end

    context "when description is present" do
      before { lesson.description = "Valid lesson description" }

      it "is valid" do
        expect(lesson).to be_valid
      end
    end

    context "when description is blank" do
      before { lesson.description = "" }

      it "is invalid" do
        expect(lesson).not_to be_valid
      end

      it "has description blank error message" do
        lesson.valid?
        expect(lesson.errors[:description]).to include("can't be blank")
      end
    end

    context "when position is present" do
      before { lesson.position = 1 }

      it "is valid" do
        expect(lesson).to be_valid
      end
    end

    context "when position is blank" do
      before { lesson.position = nil }

      it "is invalid" do
        expect(lesson).not_to be_valid
      end

      it "has position blank error message" do
        lesson.valid?
        expect(lesson.errors[:position]).to include("can't be blank")
      end
    end
  end

  describe "scopes" do
    let(:course) { create(:course) }
    let(:user) { create(:user) }
    let!(:lesson1) { create(:lesson, course: course, position: 2, title: "Ruby Basics", created_at: 2.days.ago) }
    let!(:lesson2) { create(:lesson, course: course, position: 1, title: "Rails Intro", created_at: 1.day.ago) }
    let!(:lesson3) { create(:lesson, course: course, position: 3, title: "Testing") }

    describe ".with_user_lessons_for" do
      before do
        create(:user_lesson, user: user, lesson: lesson1)
      end

      it "includes all lessons" do
        result = Lesson.with_user_lessons_for(user)
        expect(result).to include(lesson1, lesson2, lesson3)
      end

      it "includes user lessons for the specified user" do
        result = Lesson.with_user_lessons_for(user)
        lesson_with_user_lesson = result.find { |l| l.id == lesson1.id }
        expect(lesson_with_user_lesson.user_lessons).not_to be_empty
      end
    end

    describe ".by_position" do
      it "orders lessons by position ascending" do
        expect(Lesson.by_position).to eq([lesson2, lesson1, lesson3])
      end
    end

    describe ".by_content" do
      context "when query is present" do
        it "includes lessons with matching title" do
          expect(Lesson.by_content("Ruby")).to include(lesson1)
        end

        it "excludes lessons without matching title" do
          expect(Lesson.by_content("Ruby")).not_to include(lesson2, lesson3)
        end
      end

      context "when query is blank" do
        it "returns all lessons" do
          expect(Lesson.by_content("")).to include(lesson1, lesson2, lesson3)
        end
      end
    end

    describe ".by_time" do
      context "when filter is today" do
        before do
          allow(Settings.filter_days).to receive(:today).and_return("today")
        end

        it "includes lessons created today" do
          expect(Lesson.by_time("today")).to include(lesson3)
        end

        it "excludes lessons not created today" do
          expect(Lesson.by_time("today")).not_to include(lesson1, lesson2)
        end
      end

      context "when filter is last_7_days" do
        before do
          allow(Settings.filter_days).to receive(:last_7_days).and_return("last_7_days")
          allow(Settings.word).to receive(:filter_days).and_return({"last_7_days" => "7"})
        end

        it "returns lessons from last 7 days" do
          result = Lesson.by_time("last_7_days")
          expect(result).to include(lesson1, lesson2, lesson3)
        end
      end

      context "when filter is last_30_days" do
        before do
          allow(Settings.filter_days).to receive(:last_30_days).and_return("last_30_days")
          allow(Settings.word).to receive(:filter_days).and_return({"last_30_days" => "30"})
        end

        it "returns lessons from last 30 days" do
          result = Lesson.by_time("last_30_days")
          expect(result).to include(lesson1, lesson2, lesson3)
        end
      end

      context "when filter is invalid" do
        it "returns all lessons" do
          expect(Lesson.by_time("invalid")).to include(lesson1, lesson2, lesson3)
        end
      end
    end
  end

  describe "nested attributes" do
    let(:lesson) { build(:lesson) }

    it "accepts nested attributes for components" do
      expect(lesson).to respond_to(:components_attributes=)
    end
  end
end
