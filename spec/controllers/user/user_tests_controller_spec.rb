require "rails_helper"

RSpec.describe User::UserTestsController, type: :controller do
  let(:user) { create(:user, :user_role) }
  let(:course) { create(:course) }
  let(:lesson) { create(:lesson, course: course) }
  let(:test) { create(:test, max_attempts: 3, duration: 30) }
  let(:test_component) { create(:component, :test, lesson: lesson, test: test) }
  let(:test_result) { create(:test_result, user: user, component: test_component, test: test) }

  shared_context "logged in user" do
    before { log_in_as(user) }
  end

  describe "POST #create" do
    include_context "logged in user"

    context "when creating a new test attempt" do
      before do
        post :create, params: { lesson_id: lesson.id }
      end

      it "redirects to edit test path" do
        test_result = TestResult.last
        expect(response).to redirect_to(edit_user_lesson_user_test_path(lesson, test_result))
      end
    end

    context "when creating a new test attempt" do
      before do
        post :create, params: { lesson_id: lesson.id }
      end

      it "creates a new test result" do
        expect(TestResult.count).to eq(1)
      end
    end

    context "when creating a new test attempt" do
      before do
        post :create, params: { lesson_id: lesson.id }
      end

      it "sets correct user for test result" do
        test_result = TestResult.last
        expect(test_result.user).to eq(user)
      end
    end

    context "when creating a new test attempt" do
      before do
        post :create, params: { lesson_id: lesson.id }
      end

      it "sets correct component for test result" do
        test_result = TestResult.last
        expect(test_result.component).to eq(test_component)
      end
    end

    context "when creating a new test attempt" do
      before do
        post :create, params: { lesson_id: lesson.id }
      end

      it "sets test result as not submitted" do
        test_result = TestResult.last
        expect(test_result.submitted).to be_falsey
      end
    end

    context "when lesson does not exist" do
      before { post :create, params: { lesson_id: -1 } }

      it "redirects to courses path" do
        expect(response).to redirect_to(user_courses_path)
      end
    end

    context "when lesson does not exist" do
      before { post :create, params: { lesson_id: -1 } }

      it "sets danger flash message" do
        expect(flash[:danger]).to eq(I18n.t(".error.lesson_not_found"))
      end
    end

    context "when test component does not exist" do
      before do
        lesson_without_test = create(:lesson, course: course)
        post :create, params: { lesson_id: lesson_without_test.id }
      end

      it "redirects to lesson path" do
        lesson_without_test = Lesson.last
        expect(response).to redirect_to(user_course_lesson_path(course, lesson_without_test))
      end
    end

    context "when test component does not exist" do
      before do
        lesson_without_test = create(:lesson, course: course)
        post :create, params: { lesson_id: lesson_without_test.id }
      end

      it "sets danger flash message" do
        expect(flash[:danger]).to eq(I18n.t(".error.test_not_found"))
      end
    end

    context "when max attempts reached" do
      before do
        create_list(:test_result, 3, user: user, component: test_component, test: test)
        post :create, params: { lesson_id: lesson.id }
      end

      it "redirects to lesson path" do
        expect(response).to redirect_to(user_course_lesson_path(course, lesson))
      end
    end

    context "when max attempts reached" do
      before do
        create_list(:test_result, 3, user: user, component: test_component, test: test)
        post :create, params: { lesson_id: lesson.id }
      end

      it "sets danger flash message with max attempts" do
        expect(flash[:danger]).to eq(I18n.t(".error.max_attempts_reached", max_attempts: 3))
      end
    end
  end

  describe "GET #edit" do
    include_context "logged in user"

    context "when test result exists and belongs to user" do
      before { get :edit, params: { lesson_id: lesson.id, id: test_result.id } }

      it "returns successful response" do
        expect(response).to have_http_status(:ok)
      end
    end

    context "when test result exists and belongs to user" do
      before { get :edit, params: { lesson_id: lesson.id, id: test_result.id } }

      it "assigns test result" do
        expect(assigns(:test_result)).to eq(test_result)
      end
    end

    context "when test result exists and belongs to user" do
      before { get :edit, params: { lesson_id: lesson.id, id: test_result.id } }

      it "assigns test" do
        expect(assigns(:test)).to eq(test)
      end
    end

    context "when test result exists and belongs to user" do
      before { get :edit, params: { lesson_id: lesson.id, id: test_result.id } }

      it "assigns questions" do
        expect(assigns(:questions)).to be_present
      end
    end

    context "when test result does not exist" do
      before { get :edit, params: { lesson_id: lesson.id, id: -1 } }

      it "redirects to lesson path" do
        expect(response).to redirect_to(user_course_lesson_path(lesson.course, lesson))
      end
    end

    context "when test result does not exist" do
      before { get :edit, params: { lesson_id: lesson.id, id: -1 } }

      it "sets danger flash message" do
        expect(flash[:danger]).to eq(I18n.t(".error.test_result_not_found"))
      end
    end

    context "when test result belongs to different user" do
      before do
        other_user = create(:user, :user_role)
        other_test_result = create(:test_result, user: other_user, component: test_component, test: test)
        get :edit, params: { lesson_id: lesson.id, id: other_test_result.id }
      end

      it "redirects to root path" do
        expect(response).to redirect_to(root_path)
      end
    end

    context "when test result belongs to different user" do
      before do
        other_user = create(:user, :user_role)
        other_test_result = create(:test_result, user: other_user, component: test_component, test: test)
        get :edit, params: { lesson_id: lesson.id, id: other_test_result.id }
      end

      it "sets danger flash message" do
        expect(flash[:danger]).to eq(I18n.t(".error.unauthorized_access"))
      end
    end
  end

  describe "PATCH #update" do
    include_context "logged in user"

    context "when saving draft" do
      before do
        patch :update, params: {
          lesson_id: lesson.id,
          id: test_result.id,
          save_draft: "true",
          answers: { "1" => ["1"] }
        }
      end

      it "redirects to edit test path" do
        expect(response).to redirect_to(edit_user_lesson_user_test_path(lesson, test_result))
      end
    end

    context "when saving draft" do
      before do
        patch :update, params: {
          lesson_id: lesson.id,
          id: test_result.id,
          save_draft: "true",
          answers: { "1" => ["1"] }
        }
      end

      it "sets success flash message" do
        expect(flash[:success]).to eq(I18n.t(".draft_saved"))
      end
    end

    context "when saving draft" do
      before do
        patch :update, params: {
          lesson_id: lesson.id,
          id: test_result.id,
          save_draft: "true",
          answers: { "1" => ["1"] }
        }
      end

      it "updates user answers" do
        test_result.reload
        expect(test_result.user_answers).to be_present
      end
    end

    context "when submitting final answers" do
      before do
        allow(TestGradingService).to receive(:call).and_return(double(passed: true, correct_count: 5, total_questions: 10))
        patch :update, params: {
          lesson_id: lesson.id,
          id: test_result.id,
          answers: { "1" => ["1"] }
        }
      end

      it "redirects to lesson path" do
        expect(response).to redirect_to(user_course_lesson_path(course, lesson))
      end
    end

    context "when submitting final answers" do
      before do
        allow(TestGradingService).to receive(:call).and_return(double(passed: true, correct_count: 5, total_questions: 10))
        patch :update, params: {
          lesson_id: lesson.id,
          id: test_result.id,
          answers: { "1" => ["1"] }
        }
      end

      it "marks test as submitted" do
        test_result.reload
        expect(test_result.submitted).to be_truthy
      end
    end
  end
end
