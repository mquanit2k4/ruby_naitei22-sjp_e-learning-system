require "rails_helper"

RSpec.describe User::TestResultsController, type: :controller do
  let(:user) { create(:user, :user_role) }
  let(:course) { create(:course) }
  let(:lesson) { create(:lesson, course: course) }
  let(:test) { create(:test) }
  let(:test_component) { create(:component, :test, lesson: lesson, test: test) }
  let(:test_result) { create(:test_result, user: user, component: test_component, test: test) }

  shared_context "logged in user" do
    before { log_in_as(user) }
  end

  describe "GET #show" do
    include_context "logged in user"

    context "when all resources exist and user is authorized" do
      before do
        get :show, params: {
          course_id: course.id,
          lesson_id: lesson.id,
          id: test_result.id
        }
      end

      it "returns successful response" do
        expect(response).to have_http_status(:ok)
      end

      it "assigns course" do
        expect(assigns(:course)).to eq(course)
      end

      it "assigns lesson" do
        expect(assigns(:lesson)).to eq(lesson)
      end

      it "assigns test result" do
        expect(assigns(:test_result)).to eq(test_result)
      end

      it "assigns test component" do
        expect(assigns(:test_component)).to eq(test_component)
      end

      it "assigns test" do
        expect(assigns(:test)).to eq(test)
      end

      it "assigns questions data" do
        expect(assigns(:questions)).to be_present
      end

      it "assigns user answers data" do
        expect(assigns(:user_answers_data)).to be_present
      end
    end

    context "when course does not exist" do
      before do
        get :show, params: {
          course_id: -1,
          lesson_id: lesson.id,
          id: test_result.id
        }
      end

      it "redirects to root path" do
        expect(response).to redirect_to(root_path)
      end
    end

    context "when course does not exist" do
      before do
        get :show, params: {
          course_id: -1,
          lesson_id: lesson.id,
          id: test_result.id
        }
      end

      it "sets danger flash message" do
        expect(flash[:danger]).to eq(I18n.t(".error.course_or_lesson_not_found"))
      end
    end

    context "when lesson does not exist" do
      before do
        get :show, params: {
          course_id: course.id,
          lesson_id: -1,
          id: test_result.id
        }
      end

      it "redirects to root path" do
        expect(response).to redirect_to(root_path)
      end
    end

    context "when lesson does not exist" do
      before do
        get :show, params: {
          course_id: course.id,
          lesson_id: -1,
          id: test_result.id
        }
      end

      it "sets danger flash message" do
        expect(flash[:danger]).to eq(I18n.t(".error.course_or_lesson_not_found"))
      end
    end

    context "when test result does not exist" do
      before do
        get :show, params: {
          course_id: course.id,
          lesson_id: lesson.id,
          id: -1
        }
      end

      it "redirects to lesson path" do
        expect(response).to redirect_to(user_course_lesson_path(course, lesson))
      end
    end

    context "when test result does not exist" do
      before do
        get :show, params: {
          course_id: course.id,
          lesson_id: lesson.id,
          id: -1
        }
      end

      it "sets danger flash message" do
        expect(flash[:danger]).to eq(I18n.t(".error.test_result_not_found"))
      end
    end

    context "when test result belongs to different user" do
      before do
        other_user = create(:user, :user_role)
        other_test_result = create(:test_result, user: other_user, component: test_component, test: test)
        get :show, params: {
          course_id: course.id,
          lesson_id: lesson.id,
          id: other_test_result.id
        }
      end

      it "redirects to root path" do
        expect(response).to redirect_to(root_path)
      end
    end

    context "when test result belongs to different user" do
      before do
        other_user = create(:user, :user_role)
        other_test_result = create(:test_result, user: other_user, component: test_component, test: test)
        get :show, params: {
          course_id: course.id,
          lesson_id: lesson.id,
          id: other_test_result.id
        }
      end

      it "sets danger flash message" do
        expect(flash[:danger]).to eq(I18n.t(".error.unauthorized_access"))
      end
    end

    context "when user is not logged in" do
      before do
        get :show, params: {
          course_id: course.id,
          lesson_id: lesson.id,
          id: test_result.id
        }
      end

      it "redirects to login page" do
        expect(response).to redirect_to(login_url)
      end
    end

    context "when user is not logged in" do
      before do
        get :show, params: {
          course_id: course.id,
          lesson_id: lesson.id,
          id: test_result.id
        }
      end

      it "sets danger flash message" do
        expect(flash[:danger]).to eq(I18n.t("flash.please_log_in"))
      end
    end
  end
end
