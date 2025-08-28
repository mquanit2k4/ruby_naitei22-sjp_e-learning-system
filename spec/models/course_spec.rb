require "rails_helper"

RSpec.describe Course, type: :model do
  include_context "model validations"
  include_context "factory tests"

  describe "associations" do
    it { should belong_to(:creator).class_name("User").with_foreign_key("created_by_id") }
    it { should have_many(:lessons).dependent(:destroy) }
    it { should have_many(:user_courses).dependent(:destroy) }
    it { should have_many(:users).through(:user_courses) }
    it { should have_many(:admin_course_managers).dependent(:destroy) }
    it { should have_many(:admins).through(:admin_course_managers).source(:user) }
    it { should have_many(:approved_user_courses).dependent(:destroy) }
    it { should have_one_attached(:thumbnail) }
  end

  describe "validations" do
    let(:course) { build(:course) }

    context "when all fields are valid" do
      it "is valid" do
        expect(course).to be_valid
      end
    end

    context "when title validation" do
      include_examples "validates presence of", :title
      include_examples "validates uniqueness of", :title
      include_examples "validates length of", :title, minimum: 5, maximum: 100
    end

    context "when description validation" do
      include_examples "validates presence of", :description
    end

    context "when duration validation" do
      context "when duration is positive" do
        before { course.duration = 30 }

        it "is valid" do
          expect(course).to be_valid
        end
      end

      context "when duration is blank" do
        before { course.duration = nil }

        it "is invalid" do
          expect(course).not_to be_valid
        end

        it "has duration blank error message" do
          course.valid?
          expect(course.errors[:duration]).to include("can't be blank")
        end
      end

      include_examples "validates numericality of", :duration, greater_than: 0
    end
  end

  describe "factory" do
    include_examples "has valid factory", :course
  end

  describe "scopes" do
    let!(:course1) { create(:course, title: "Ruby Programming", created_at: 2.days.ago) }
    let!(:course2) { create(:course, title: "Rails Development", created_at: 1.day.ago) }
    let!(:course3) { create(:course, title: "JavaScript Basics") }

    describe ".recent" do
      it "orders courses by created_at desc" do
        expect(Course.recent).to eq([course3, course2, course1])
      end
    end

    describe ".search_name" do
      context "when keyword is present" do
        it "returns courses with matching title" do
          expect(Course.search_name("Ruby")).to include(course1)
        end

        it "does not return non-matching courses" do
          expect(Course.search_name("Ruby")).not_to include(course2, course3)
        end
      end

      context "when keyword is blank" do
        it "returns all courses" do
          expect(Course.search_name("")).to include(course1, course2, course3)
        end
      end
    end

    describe ".with_status_for_user" do
      let(:user) { create(:user) }
      let!(:user_course) { create(:user_course, user: user, course: course1, enrolment_status: :approved) }

      context "when status is not_enrolled" do
        it "returns courses user is not enrolled in" do
          result = Course.with_status_for_user(:not_enrolled, user)
          expect(result).to include(course2, course3)
        end

        it "does not return enrolled courses" do
          result = Course.with_status_for_user(:not_enrolled, user)
          expect(result).not_to include(course1)
        end
      end

      context "when status is specific enrollment status" do
        it "returns courses with that status for user" do
          result = Course.with_status_for_user(:approved, user)
          expect(result).to include(course1)
        end

        it "does not return courses without that status" do
          result = Course.with_status_for_user(:approved, user)
          expect(result).not_to include(course2, course3)
        end
      end

      context "when user is nil" do
        it "returns all courses" do
          result = Course.with_status_for_user(:approved, nil)
          expect(result).to include(course1, course2, course3)
        end
      end
    end
  end

  describe "instance methods" do
    let(:user) { create(:user) }
    let(:course) { create(:course) }
    let!(:lesson1) { create(:lesson, course: course) }
    let!(:lesson2) { create(:lesson, course: course) }

    describe "#progress_percentage_for_user" do
      context "when course has no lessons" do
        let(:empty_course) { create(:course) }

        it "returns 0" do
          expect(empty_course.progress_percentage_for_user(user)).to eq(0)
        end
      end

      context "when user has completed some lessons" do
        before do
          allow(UserLesson).to receive(:count_for_user_and_lessons)
            .with(user, [lesson1.id, lesson2.id])
            .and_return(1)
        end

        it "returns correct percentage" do
          expect(course.progress_percentage_for_user(user)).to eq(50)
        end
      end

      context "when user has completed all lessons" do
        before do
          allow(UserLesson).to receive(:count_for_user_and_lessons)
            .with(user, [lesson1.id, lesson2.id])
            .and_return(2)
        end

        it "returns 100" do
          expect(course.progress_percentage_for_user(user)).to eq(100)
        end
      end
    end
  end

  describe "callbacks" do
    let(:admin1) { create(:user, :admin) }
    let(:admin2) { create(:user, :admin) }

    context "when course_admin_ids is present" do
      it "assigns admin managers after save" do
        course = build(:course, course_admin_ids: [admin1.id, admin2.id])

        expect do
          course.save!
        end.to change(AdminCourseManager, :count).by(2)
      end

      it "includes assigned admins" do
        course = create(:course, course_admin_ids: [admin1.id, admin2.id])
        expect(course.admins).to include(admin1, admin2)
      end
    end

    context "when course_admin_ids is blank" do
      it "does not assign admin managers" do
        course = build(:course, course_admin_ids: [])

        expect do
          course.save!
        end.not_to change(AdminCourseManager, :count)
      end
    end
  end
end
