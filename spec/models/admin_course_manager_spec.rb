require "rails_helper"

RSpec.describe AdminCourseManager, type: :model do
  include_context "factory tests"

  describe "associations" do
    it { should belong_to(:user) }
    it { should belong_to(:course) }
  end

  describe "validations" do
    let(:user) { create(:user, :admin) }
    let(:course) { create(:course) }

    context "when creating admin course manager with valid associations" do
      let(:admin_course_manager) { build(:admin_course_manager, user: user, course: course) }

      it "is valid" do
        expect(admin_course_manager).to be_valid
      end
    end

    context "when creating admin course manager without user" do
      let(:admin_course_manager) { build(:admin_course_manager, user: nil, course: course) }

      it "is invalid" do
        expect(admin_course_manager).not_to be_valid
      end

      it "has user must exist error message" do
        admin_course_manager.valid?
        expect(admin_course_manager.errors[:user]).to include("must exist")
      end
    end

    context "when creating admin course manager without course" do
      let(:admin_course_manager) { build(:admin_course_manager, user: user, course: nil) }

      it "is invalid" do
        expect(admin_course_manager).not_to be_valid
      end

      it "has course must exist error message" do
        admin_course_manager.valid?
        expect(admin_course_manager.errors[:course]).to include("must exist")
      end
    end
  end

  describe "factory" do
    include_examples "has valid factory", :admin_course_manager

    context "when using default factory" do
      let(:admin_course_manager) { build(:admin_course_manager) }

      it "has associated user" do
        expect(admin_course_manager.user).to be_present
      end

      it "has associated course" do
        expect(admin_course_manager.course).to be_present
      end
    end
  end
end
