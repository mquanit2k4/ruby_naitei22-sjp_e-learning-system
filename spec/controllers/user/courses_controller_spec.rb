require "rails_helper"

RSpec.describe User::CoursesController, type: :controller do
  let(:user) { create(:user, :user_role) }
  let(:course) { create(:course) }
  let(:user_course) { create(:user_course, user: user, course: course) }

  shared_context "logged in user" do
    before { log_in_as(user) }
  end

  describe "GET #index" do
    context "when user is logged in" do
      include_context "logged in user"

      before do
        create_list(:course, 3)
        get :index
      end

      it "returns successful response" do
        expect(response).to have_http_status(:ok)
      end

      it "assigns courses with pagination" do
        expect(assigns(:courses)).to be_present
      end

      it "assigns pagy object" do
        expect(assigns(:pagy)).to be_present
      end
    end

    context "when user is not logged in" do
      before { get :index }

      it "returns successful response for guest access" do
        expect(response).to have_http_status(:ok)
      end
    end

    context "when guest tries to access status filter" do
      before { get :index, params: { status: "approved" } }

      it "redirects to courses path" do
        expect(response).to redirect_to(user_courses_path)
      end

      it "sets alert flash message" do
        expect(flash[:alert]).to eq(I18n.t("flash.please_log_in"))
      end
    end
  end

  describe "GET #show" do
    include_context "logged in user"

    context "when course exists and user is enrolled" do
      before do
        create(:user_course, user: user, course: course, enrolment_status: :approved)
        get :show, params: { id: course.id }
      end

      it "returns successful response" do
        expect(response).to have_http_status(:ok)
      end

      it "assigns course" do
        expect(assigns(:course)).to eq(course)
      end
    end

    context "when course does not exist" do
      before { get :show, params: { id: -1 } }

      it "redirects to root path" do
        expect(response).to redirect_to(root_path)
      end

      it "sets danger flash message" do
        expect(flash[:danger]).to eq(I18n.t(".error.course_not_found"))
      end
    end

    context "when user is not enrolled" do
      before { get :show, params: { id: course.id } }

      it "redirects to courses path" do
        expect(response).to redirect_to(user_courses_path)
      end

      it "sets danger flash message" do
        expect(flash[:danger]).to eq(I18n.t(".error.not_enrolled"))
      end
    end
  end

  describe "POST #enroll" do
    include_context "logged in user"

    context "when course exists and user not enrolled" do
      before { post :enroll, params: { id: course.id } }

      it "redirects to courses path" do
        expect(response).to redirect_to(user_courses_path)
      end

      it "creates user course enrollment" do
        expect(UserCourse.where(user: user, course: course)).to exist
      end

      it "sets success flash message" do
        expect(flash[:success]).to eq(I18n.t(".success_enrolled"))
      end
    end

    context "when user already enrolled" do
      before do
        create(:user_course, user: user, course: course)
        post :enroll, params: { id: course.id }
      end

      it "redirects to courses path" do
        expect(response).to redirect_to(user_courses_path)
      end

      it "sets warning flash message" do
        expect(flash[:warning]).to eq(I18n.t(".already_enrolled"))
      end
    end

    context "when course does not exist" do
      before { post :enroll, params: { id: -1 } }

      it "redirects to root path" do
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "PATCH #start" do
    include_context "logged in user"

    context "when user course is approved" do
      before do
        create(:user_course, user: user, course: course, enrolment_status: :approved)
        patch :start, params: { id: course.id }
      end

      it "redirects to course path" do
        expect(response).to redirect_to(user_course_path(course))
      end

      it "updates course status to in_progress" do
        user_course = UserCourse.find_by(user: user, course: course)
        expect(user_course.enrolment_status).to eq("in_progress")
      end

      it "sets success flash message" do
        expect(flash[:success]).to eq(I18n.t(".success"))
      end
    end

    context "when user course is not approved" do
      before do
        create(:user_course, user: user, course: course, enrolment_status: :pending)
        patch :start, params: { id: course.id }
      end

      it "redirects to courses path" do
        expect(response).to redirect_to(user_courses_path)
      end

      it "sets danger flash message" do
        expect(flash[:danger]).to eq(I18n.t(".invalid_status"))
      end
    end
  end
end
