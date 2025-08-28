require "rails_helper"

RSpec.describe Word, type: :model do
  describe "associations" do
    it { should have_many(:components).dependent(:destroy) }
  end

  describe "validations" do
    let(:word) { build(:word) }

    context "when all fields are valid" do
      it "is valid" do
        expect(word).to be_valid
      end
    end

    context "when content is present" do
      it "is valid" do
        word.content = "hello"
        expect(word).to be_valid
      end
    end

    context "when content is blank" do
      it "is invalid" do
        word.content = ""
        expect(word).not_to be_valid
      end

      it "has content error message" do
        word.content = ""
        word.valid?
        expect(word.errors[:content]).to include("can't be blank")
      end
    end

    context "when meaning is present" do
      it "is valid" do
        word.meaning = "greeting"
        expect(word).to be_valid
      end
    end

    context "when meaning is blank" do
      it "is invalid" do
        word.meaning = ""
        expect(word).not_to be_valid
      end

      it "has meaning error message" do
        word.meaning = ""
        word.valid?
        expect(word.errors[:meaning]).to include("can't be blank")
      end
    end

    context "when word_type is valid" do
      it "is valid" do
        word.word_type = "noun"
        expect(word).to be_valid
      end
    end

    context "when word_type is blank" do
      it "is invalid" do
        word.word_type = nil
        expect(word).not_to be_valid
        expect(word.errors[:word_type]).to include("can't be blank")
      end
    end

    context "when word_type is invalid" do
      it "is invalid" do
        expect do
          word.word_type = "invalid_type"
        end.to raise_error(ArgumentError)
      end
    end
  end

  describe "enums" do
    it do
      should define_enum_for(:word_type).with_values(
        noun: 0,
        pronoun: 1,
        verb: 2,
        adjective: 3,
        adverb: 4,
        preposition: 5,
        conjunction: 6,
        interjection: 7
      )
    end
  end

  describe "scopes" do
    let!(:word1) { create(:word, content: "apple", word_type: "noun", created_at: 2.days.ago) }
    let!(:word2) { create(:word, content: "beautiful", word_type: "adjective", created_at: 1.day.ago) }
    let!(:word3) { create(:word, content: "run", word_type: "verb") }

    describe ".by_type" do
      it "includes words of specified type" do
        expect(Word.by_type("noun")).to include(word1)
      end

      it "excludes words of other types" do
        expect(Word.by_type("noun")).not_to include(word2, word3)
      end
    end

    describe ".recent" do
      it "orders words by created_at desc" do
        expect(Word.recent).to eq([word3, word2, word1])
      end
    end

    describe ".by_content" do
      context "when query is present" do
        it "includes words with matching content" do
          expect(Word.by_content("app")).to include(word1)
        end

        it "excludes words without matching content" do
          expect(Word.by_content("app")).not_to include(word2, word3)
        end
      end

      context "when query is blank" do
        it "returns all words" do
          expect(Word.by_content("")).to include(word1, word2, word3)
        end
      end
    end

    describe ".by_time" do
      context "when filter is today" do
        before do
          allow(Settings.filter_days).to receive(:today).and_return("today")
        end

        it "includes words created today" do
          expect(Word.by_time("today")).to include(word3)
        end

        it "excludes words not created today" do
          expect(Word.by_time("today")).not_to include(word1, word2)
        end
      end

      context "when filter is last_7_days" do
        before do
          allow(Settings.filter_days).to receive(:last_7_days).and_return("last_7_days")
          allow(Settings.word).to receive(:filter_days).and_return({"last_7_days" => "7"})
        end

        it "returns words from last 7 days" do
          result = Word.by_time("last_7_days")
          expect(result).to include(word1, word2, word3)
        end
      end

      context "when filter is invalid" do
        it "returns all words" do
          expect(Word.by_time("invalid")).to include(word1, word2, word3)
        end
      end
    end

    describe ".search" do
      let!(:word_apple) { create(:word, content: "apple", meaning: "fruit") }
      let!(:word_application) { create(:word, content: "application", meaning: "software") }

      context "when searching by content field" do
        it "returns words with matching content prefix" do
          result = Word.search("app", :content)
          expect(result).to include(word_apple, word_application)
        end
      end

      context "when searching by meaning field" do
        it "includes words with matching meaning prefix" do
          result = Word.search("fruit", :meaning)
          expect(result).to include(word_apple)
        end

        it "excludes words without matching meaning prefix" do
          result = Word.search("fruit", :meaning)
          expect(result).not_to include(word_application)
        end
      end

      context "when searching without field specified" do
        it "searches both content and meaning" do
          result = Word.search("app")
          expect(result).to include(word_apple, word_application)
        end
      end

      context "when query is blank" do
        it "returns all words" do
          expect(Word.search("")).to include(word_apple, word_application)
        end
      end
    end

    describe ".filter_by_type" do
      context "when type is specified" do
        it "includes words of specified type" do
          result = Word.filter_by_type("noun")
          expect(result).to include(word1)
        end

        it "excludes words of other types" do
          result = Word.filter_by_type("noun")
          expect(result).not_to include(word2, word3)
        end
      end

      context "when type is all" do
        it "returns all words" do
          expect(Word.filter_by_type("all")).to include(word1, word2, word3)
        end
      end

      context "when type is blank" do
        it "returns all words" do
          expect(Word.filter_by_type("")).to include(word1, word2, word3)
        end
      end
    end

    describe ".sorted" do
      context "when sort is alphabetical_desc" do
        it "orders by content descending" do
          result = Word.sorted(:alphabetical_desc)
          expect(result.first.content).to eq("run")
        end

        it "has correct last item when ordered by content desc" do
          result = Word.sorted(:alphabetical_desc)
          expect(result.last.content).to eq("apple")
        end
      end

      context "when sort is newest" do
        it "orders by created_at desc" do
          expect(Word.sorted(:newest)).to eq([word3, word2, word1])
        end
      end

      context "when sort is oldest" do
        it "orders by created_at asc" do
          expect(Word.sorted(:oldest)).to eq([word1, word2, word3])
        end
      end

      context "when sort is word_type" do
        it "orders by word_type then content" do
          result = Word.sorted(:word_type)
          noun_words = result.select { |w| w.word_type == "noun" }
          expect(noun_words.first).to eq(word1)
        end
      end

      context "when sort is default" do
        it "has correct first item when ordered by content asc" do
          result = Word.sorted(:default)
          expect(result.first.content).to eq("apple")
        end

        it "has correct last item when ordered by content asc" do
          result = Word.sorted(:default)
          expect(result.last.content).to eq("run")
        end
      end
    end

    describe ".filter_by_status" do
      let(:user) { create(:user) }
      let(:component) { create(:component, :word, word: word1) }

      context "when status is learned" do
        before do
          create(:user_word, user: user, component: component)
        end

        it "returns learned words for user" do
          result = Word.filter_by_status(:learned, user)
          expect(result).to include(word1)
        end
      end

      context "when status is not_learned" do
        it "returns not learned words for user" do
          result = Word.filter_by_status(:not_learned, user)
          expect(result).to include(word1, word2, word3)
        end
      end

      context "when status is blank" do
        it "returns all words" do
          expect(Word.filter_by_status("", user)).to include(word1, word2, word3)
        end
      end
    end
  end

  describe "class methods" do
    describe ".learned_word_ids_for" do
      let(:user) { create(:user) }
      let(:word) { create(:word) }
      let(:component) { create(:component, :word, word: word) }

      context "when user has learned words" do
        before do
          create(:user_word, user: user, component: component)
        end

        it "returns array of learned word ids" do
          result = Word.learned_word_ids_for(user)
          expect(result).to include(word.id)
        end
      end

      context "when user has no learned words" do
        it "returns empty array" do
          result = Word.learned_word_ids_for(user)
          expect(result).to be_empty
        end
      end
    end
  end

  describe "instance methods" do
    let(:user) { create(:user) }
    let(:word) { create(:word) }
    let(:component) { create(:component, :word, word: word) }

    describe "#learned_by?" do
      context "when user has learned the word" do
        before do
          create(:user_word, user: user, component: component)
        end

        it "returns true" do
          expect(word.learned_by?(user)).to be true
        end
      end

      context "when user has not learned the word" do
        it "returns false" do
          expect(word.learned_by?(user)).to be false
        end
      end
    end
  end
end
