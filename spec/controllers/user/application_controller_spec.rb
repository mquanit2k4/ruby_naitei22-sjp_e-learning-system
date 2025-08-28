require "rails_helper"

RSpec.describe User::ApplicationController, type: :controller do
  controller do
    def index
      render plain: "success"
    end
  end

  describe "before_action callbacks" do
    context "when user is not logged in" do
      it "redirects to login page" do
        get :index
        expect(response).to redirect_to(login_url)
      end

      it "sets danger flash message" do
        get :index
        expect(flash[:danger]).to eq(I18n.t("flash.please_log_in"))
      end
    end

    context "when user is logged in but not user role" do
      before do
        admin_user = create(:user, :admin)
        log_in_as(admin_user)
      end

      it "redirects to root path" do
        get :index
        expect(response).to redirect_to(root_path)
      end

      it "sets danger flash message" do
        get :index
        expect(flash[:danger]).to eq(I18n.t(".error.not_authenticated"))
      end
    end

    context "when user is logged in with user role" do
      before do
        user = create(:user, :user_role)
        log_in_as(user)
      end

      it "allows access to controller action" do
        get :index
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
