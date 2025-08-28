require "rails_helper"

RSpec.describe User, type: :model do
  describe "associations" do
    it { should have_many(:created_courses).class_name("Course").with_foreign_key("created_by_id").dependent(:nullify) }
    it { should have_many(:created_lessons).class_name("Lesson").with_foreign_key("created_by_id").dependent(:nullify) }
    it { should have_many(:user_courses).dependent(:destroy) }
    it { should have_many(:enrolled_courses).through(:user_courses).source(:course) }
    it { should have_many(:user_lessons).dependent(:destroy) }
    it { should have_many(:lessons).through(:user_lessons) }
    it { should have_many(:admin_course_managers).dependent(:destroy) }
    it { should have_many(:managed_courses).through(:admin_course_managers).source(:course) }
    it { should have_many(:user_words).dependent(:destroy) }
    it { should have_many(:test_results).dependent(:destroy) }
    it { should have_one_attached(:avatar) }
  end

  describe "validations" do
    let(:user) { build(:user) }

    context "when all fields are valid" do
      it "is valid" do
        expect(user).to be_valid
      end
    end

    context "when name validation" do
      context "when name is present" do
        before { user.name = "Valid Name" }

        it "is valid" do
          expect(user).to be_valid
        end
      end

      context "when name is blank" do
        before { user.name = "" }

        it "is invalid" do
          expect(user).not_to be_valid
        end

        it "has name blank error message" do
          user.valid?
          expect(user.errors[:name]).to include("can't be blank")
        end
      end

      context "when name is too long" do
        before { user.name = "a" * 256 }

        it "is invalid" do
          expect(user).not_to be_valid
        end
      end
    end

    context "when email validation" do
      context "when email is valid" do
        before { user.email = "test@example.com" }

        it "is valid" do
          expect(user).to be_valid
        end
      end

      context "when email is blank" do
        before { user.email = "" }

        it "is invalid" do
          expect(user).not_to be_valid
        end

        it "has email blank error message" do
          user.valid?
          expect(user.errors[:email]).to include("can't be blank")
        end
      end

      context "when email format is invalid" do
        before { user.email = "invalid_email" }

        it "is invalid" do
          expect(user).not_to be_valid
        end

        it "has email format error message" do
          user.valid?
          expect(user.errors[:email]).to include("is invalid")
        end
      end

      context "when email is not unique" do
        let!(:existing_user) { create(:user, email: "test@example.com") }

        before { user.email = "test@example.com" }

        it "is invalid" do
          expect(user).not_to be_valid
        end

        it "has email uniqueness error message" do
          user.valid?
          expect(user.errors[:email]).to include("has already been taken")
        end
      end
    end

    context "when birthday validation" do
      context "when birthday is present" do
        before { user.birthday = 20.years.ago }

        it "is valid" do
          expect(user).to be_valid
        end
      end

      context "when birthday is blank for non-oauth user" do
        before do
          user.birthday = nil
          user.provider = nil
          user.uid = nil
        end

        it "is invalid" do
          expect(user).not_to be_valid
        end

        it "has birthday blank error message" do
          user.valid?
          expect(user.errors[:birthday]).to include("can't be blank")
        end
      end

      context "when birthday is in the future" do
        before { user.birthday = 1.day.from_now }

        it "is invalid" do
          expect(user).not_to be_valid
        end

        it "has future birthday error message" do
          user.valid?
          expect(user.errors[:birthday]).to include("cannot be in the future")
        end
      end

      context "when birthday is more than 100 years ago" do
        before { user.birthday = 101.years.ago }

        it "is invalid" do
          expect(user).not_to be_valid
        end

        it "has old birthday error message" do
          user.valid?
          expect(user.errors[:birthday]).to include("must be within the last 100 years")
        end
      end
    end

    context "when gender validation" do
      context "when gender is present" do
        before { user.gender = "male" }

        it "is valid" do
          expect(user).to be_valid
        end
      end

      context "when gender is blank for non-oauth user" do
        before do
          user.gender = nil
          user.provider = nil
          user.uid = nil
        end

        it "is invalid" do
          expect(user).not_to be_valid
        end

        it "has gender blank error message" do
          user.valid?
          expect(user.errors[:gender]).to include("can't be blank")
        end
      end
    end
  end

  describe "enums" do
    it { should define_enum_for(:gender).with_values(male: 0, female: 1, other: 2) }
    it { should define_enum_for(:role).with_values(user: 0, admin: 1) }
  end

  describe "class methods" do
    describe ".new_token" do
      it "generates a present token" do
        token = User.new_token
        expect(token).to be_present
      end

      it "generates a token with sufficient length" do
        token = User.new_token
        expect(token.length).to be > 10
      end
    end

    describe ".digest" do
      it "creates a present BCrypt digest" do
        string = "test_string"
        digest = User.digest(string)
        expect(digest).to be_present
      end

      it "creates a valid BCrypt digest of the string" do
        string = "test_string"
        digest = User.digest(string)
        expect(BCrypt::Password.new(digest).is_password?(string)).to be true
      end
    end

    describe ".find_or_create_from_auth_hash" do
      let(:auth_hash) do
        double(
          "auth_hash",
          provider: "google",
          uid: "123456",
          info: double(
            "info",
            name: "Test User",
            email: "test@example.com"
          )
        )
      end

      context "when user exists" do
        let!(:existing_user) { create(:user, email: "test@example.com") }

        it "returns existing user" do
          user = User.find_or_create_from_auth_hash(auth_hash)
          expect(user).to eq(existing_user)
        end

        it "updates provider info" do
          user = User.find_or_create_from_auth_hash(auth_hash)
          expect(user.provider).to eq("google")
        end

        it "updates uid info" do
          user = User.find_or_create_from_auth_hash(auth_hash)
          expect(user.uid).to eq("123456")
        end
      end

      context "when user does not exist" do
        it "creates new user" do
          expect do
            User.find_or_create_from_auth_hash(auth_hash)
          end.to change(User, :count).by(1)
        end

        it "sets correct name for new user" do
          User.find_or_create_from_auth_hash(auth_hash)
          user = User.last
          expect(user.name).to eq("Test User")
        end

        it "sets correct email for new user" do
          User.find_or_create_from_auth_hash(auth_hash)
          user = User.last
          expect(user.email).to eq("test@example.com")
        end

        it "sets correct provider for new user" do
          User.find_or_create_from_auth_hash(auth_hash)
          user = User.last
          expect(user.provider).to eq("google")
        end

        it "sets correct uid for new user" do
          User.find_or_create_from_auth_hash(auth_hash)
          user = User.last
          expect(user.uid).to eq("123456")
        end
      end
    end
  end

  describe "instance methods" do
    let(:user) { create(:user) }

    describe "#remember" do
      it "sets remember_token" do
        user.remember
        expect(user.remember_token).to be_present
      end

      it "sets remember_digest" do
        user.remember
        expect(user.remember_digest).to be_present
      end
    end

    describe "#authenticated?" do
      before { user.remember }

      context "when token matches" do
        it "returns true" do
          expect(user.authenticated?(user.remember_token)).to be true
        end
      end

      context "when token does not match" do
        it "returns false" do
          expect(user.authenticated?("wrong_token")).to be false
        end
      end

      context "when remember_digest is nil" do
        it "returns false" do
          user.update_column(:remember_digest, nil)
          expect(user.authenticated?(user.remember_token)).to be false
        end
      end
    end

    describe "#forget" do
      it "has remember_digest before forgetting" do
        user.remember
        expect(user.remember_digest).to be_present
      end

      it "clears remember_digest" do
        user.remember
        user.forget
        expect(user.remember_digest).to be_nil
      end
    end

    describe "#oauth_user?" do
      context "when provider and uid are present" do
        it "returns true" do
          user.provider = "google"
          user.uid = "123456"
          expect(user.oauth_user?).to be true
        end
      end

      context "when provider or uid is blank" do
        it "returns false" do
          user.provider = nil
          user.uid = nil
          expect(user.oauth_user?).to be false
        end
      end
    end
  end
end
