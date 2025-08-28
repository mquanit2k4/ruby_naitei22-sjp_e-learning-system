require "rails_helper"

RSpec.describe User::WordsController, type: :controller do
  let(:user) { create(:user, :user_role) }

  shared_context "logged in user" do
    before { log_in_as(user) }
  end

  describe "GET #index" do
    include_context "logged in user"

    context "when accessing words index" do
      before do
        create_list(:word, 10)
        get :index
      end

      it "returns successful response" do
        expect(response).to have_http_status(:ok)
      end

      it "assigns words with pagination" do
        expect(assigns(:words)).to be_present
      end

      it "assigns pagy object" do
        expect(assigns(:pagy)).to be_present
      end

      it "assigns learned word ids" do
        expect(assigns(:learned_ids)).to be_present
      end
    end

    context "when searching words" do
      before do
        create(:word, content: "hello", meaning: "greeting")
        create(:word, content: "world", meaning: "planet")
        get :index, params: { search: "hello" }
      end

      it "returns successful response" do
        expect(response).to have_http_status(:ok)
      end

      it "filters words by search term" do
        expect(assigns(:words)).to be_present
      end
    end

    context "when filtering by word type" do
      before do
        create(:word, word_type: "noun")
        create(:word, word_type: "verb")
        get :index, params: { word_type: "noun" }
      end

      it "returns successful response" do
        expect(response).to have_http_status(:ok)
      end
    end

    context "when user is not logged in" do
      before { get :index }

      it "redirects to login page" do
        expect(response).to redirect_to(login_url)
      end

      it "sets danger flash message" do
        expect(flash[:danger]).to eq(I18n.t("flash.please_log_in"))
      end
    end

    context "when user is admin" do
      before do
        admin_user = create(:user, :admin)
        log_in_as(admin_user)
        get :index
      end

      it "redirects to root path" do
        expect(response).to redirect_to(root_path)
      end

      it "sets danger flash message" do
        expect(flash[:danger]).to eq(I18n.t(".error.not_authenticated"))
      end
    end
  end
end
