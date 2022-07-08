require 'rails_helper'
require 'support/my_spec_helper' 

RSpec.describe Game, type: :model do
  let(:user) { FactoryBot.create(:user) }
  let(:game_w_questions) { FactoryBot.create(:game_with_questions, user: user) }

  context 'Game Factory' do
    it 'Game.create_game! new correct game' do
      generate_questions(60)

      game = nil
      expect {
        game = Game.create_game_for_user!(user)
      }.to change(Game, :count).by(1).and(
        change(GameQuestion, :count).by(15).and(
          change(Question, :count).by(0) 
        )
      )
      expect(game.user).to eq(user)
      expect(game.status).to eq(:in_progress)
      expect(game.game_questions.size).to eq(15)
      expect(game.game_questions.map(&:level)).to eq (0..14).to_a
    end
  end

  context 'game mechanics' do
    it 'answer correct continues game' do
      level = game_w_questions.current_level
      q = game_w_questions.current_game_question
      expect(game_w_questions.status).to eq(:in_progress)

      game_w_questions.answer_current_question!(q.correct_answer_key)

      expect(game_w_questions.current_level).to eq(level + 1)
      expect(game_w_questions.previous_game_question).to eq(q)
      expect(game_w_questions.current_game_question).not_to eq(q)
      expect(game_w_questions.status).to eq(:in_progress)
      expect(game_w_questions.finished?).to be_falsey
    end

    it 'take_money! finishes the game' do
      q = game_w_questions.current_game_question
      game_w_questions.answer_current_question!(q.correct_answer_key)
    
      game_w_questions.take_money!
    
      prize = game_w_questions.prize
      expect(prize).to be > 0
    
      expect(game_w_questions.status).to eq :money
      expect(game_w_questions.finished?).to be_truthy
      expect(user.balance).to eq prize
    end
  end

  context '.status' do
    before(:each) do
      game_w_questions.finished_at = Time.now
      expect(game_w_questions.finished?).to be_truthy
    end
  
    it ':won' do
      game_w_questions.current_level = Question::QUESTION_LEVELS.max + 1
      expect(game_w_questions.status).to eq(:won)
    end
  
    it ':fail' do
      game_w_questions.is_failed = true
      expect(game_w_questions.status).to eq(:fail)
    end
  
    it ':timeout' do
      game_w_questions.created_at = 1.hour.ago
      game_w_questions.is_failed = true
      expect(game_w_questions.status).to eq(:timeout)
    end
  
    it ':money' do
      expect(game_w_questions.status).to eq(:money)
    end
  end

  describe '#current_game_question' do
    it 'return current game question' do
      expect(game_w_questions.current_game_question).to eq(game_w_questions.game_questions[0])
    end
  end 

  describe '#previous_level' do
    it 'return 1' do
      game_w_questions.current_level = 2
      expect(game_w_questions.previous_level).to eq(1) 
    end
  end 

  describe '#answer_current_question!' do
    before do
      game_w_questions.answer_current_question!(answer_key)
    end

    context 'when the answer is correct' do
      let(:answer_key) { game_w_questions.current_game_question.correct_answer_key }

      it 'correct answer should return true' do
        expect(game_w_questions.answer_current_question!(answer_key)).to be true          
      end

      it "should return in_progress status" do
        expect(game_w_questions.status).to eq(:in_progress)
      end

      it "game finish should return false" do
        expect(game_w_questions.finished?).to be false
      end

      context 'when is the last answer (in a million)' do
        let(:game_w_questions) { FactoryBot.create(:game_with_questions, user: user, current_level: Question::QUESTION_LEVELS.max) }

        it "should return won status" do
          expect(game_w_questions.status).to eq(:won)
        end
  
        it "game finish should return true" do
          expect(game_w_questions.finished?).to be true
        end

        it "must contain the final prize 1000000" do
          expect(game_w_questions.prize).to eq(1000000)
        end 
      end
  
      context 'when the answer is given after the expiration of time' do
        let(:game_w_questions) { FactoryBot.create(:game_with_questions, user: user, created_at: 1.hour.ago) }

        it "should return timeout status" do
          expect(game_w_questions.status).to eq(:timeout)
        end

        it "game finish should return true" do
          expect(game_w_questions.finished?).to be true
        end
      end
    end

    context 'when the answer is wrong' do
      let(:answer_key) { (%w[a b c d] - [game_w_questions.current_game_question.correct_answer_key]).sample }

      it 'wrong answer should return false' do
        expect(game_w_questions.answer_current_question!(answer_key)).to be false          
      end

      it "should return fail status" do
        expect(game_w_questions.status).to eq(:fail)
      end

      it "game finish should return true" do
        expect(game_w_questions.finished?).to be true
      end
    end 
  end
end
