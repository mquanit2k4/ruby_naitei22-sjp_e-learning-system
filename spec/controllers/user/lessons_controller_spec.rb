require "rails_helper"

RSpec.describe User::LessonsController, type: :controller do
  let(:user) { create(:user, :user_role) }
  let(:course) { create(:course) }
  let(:lesson) { create(:lesson, course: course) }
  let(:test_component) { create(:component, :test, lesson: lesson) }
  let(:word_component) { create(:component, lesson: lesson, component_type: :word) }

  shared_context "logged in user" do
    before { log_in_as(user) }
  end

  describe "GET #show" do
    include_context "logged in user"

    context "when course and lesson exist" do
      before { get :show, params: { course_id: course.id, id: lesson.id } }

      it "returns successful response" do
        expect(response).to have_http_status(:ok)
      end

      it "assigns lesson" do
        expect(assigns(:lesson)).to eq(lesson)
      end

      it "assigns course" do
        expect(assigns(:course)).to eq(course)
      end
    end

    context "when course does not exist" do
      before { get :show, params: { course_id: -1, id: lesson.id } }

      it "redirects to root path" do
        expect(response).to redirect_to(root_path)
      end

      it "sets danger flash message" do
        expect(flash[:danger]).to eq(I18n.t(".error.course_not_found"))
      end
    end

    context "when lesson does not exist" do
      before { get :show, params: { course_id: course.id, id: -1 } }

      it "redirects to course path" do
        expect(response).to redirect_to(user_course_path(course))
      end

      it "sets danger flash message" do
        expect(flash[:danger]).to eq(I18n.t(".error.lesson_not_found"))
      end
    end
  end

  describe "GET #study" do
    include_context "logged in user"

    context "when lesson has word components" do
      before do
        word = create(:word)
        create(:component, lesson: lesson, component_type: :word, word: word)
        get :study, params: { course_id: course.id, id: lesson.id, word_index: 1 }
      end

      it "returns successful response" do
        expect(response).to have_http_status(:ok)
      end

      it "assigns word components" do
        expect(assigns(:word_components)).to be_present
      end

      it "assigns current word data" do
        expect(assigns(:current_word)).to be_present
      end
    end

    context "when lesson has no word components" do
      before { get :study, params: { course_id: course.id, id: lesson.id } }

      it "redirects to lesson path" do
        expect(response).to redirect_to(user_course_lesson_path(lesson.course, lesson))
      end

      it "sets danger flash message" do
        expect(flash[:danger]).to eq(I18n.t(".error.no_words_found"))
      end
    end
  end

  describe "GET #test_history" do
    include_context "logged in user"

    context "when test component exists" do
      before do
        test = create(:test)
        create(:component, lesson: lesson, component_type: :test, test: test)
        get :test_history, params: { course_id: course.id, id: lesson.id }
      end

      it "returns successful response" do
        expect(response).to have_http_status(:ok)
      end

      it "assigns test results" do
        expect(assigns(:test_results)).to be_present
      end
    end

    context "when test component does not exist" do
      before { get :test_history, params: { course_id: course.id, id: lesson.id } }

      it "redirects to lesson path" do
        expect(response).to redirect_to(user_course_lesson_path(course, lesson))
      end

      it "sets danger flash message" do
        expect(flash[:danger]).to eq(I18n.t(".error.test_not_found"))
      end
    end
  end
end
