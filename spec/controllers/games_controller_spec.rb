require 'rails_helper'
require 'support/my_spec_helper'

RSpec.describe GamesController, type: :controller do
  let(:user) { FactoryBot.create(:user) }
  let(:admin) { FactoryBot.create(:user, is_admin: true) }
  let(:game_w_questions) { FactoryBot.create(:game_with_questions, user: user) }

  describe '#show' do
    context "when anonim" do
      before { get :show, id: game_w_questions.id }

      it "status is not 200 OK" do
        expect(response.status).not_to eq(200)
      end

      it "should redirect to authorization" do
        expect(response).to redirect_to(new_user_session_path)
      end

      it "it must be flash alert" do
        expect(flash[:alert]).to be
      end
    end

    context 'when authorized user' do
      before do
        sign_in user
        get :show, id: game_w_questions.id
      end

      let(:game) { assigns(:game) } 

      it "return false" do
        expect(game.finished?).to be false
      end

      it "user must be" do
        expect(game.user).to eq(user)
      end

      it "status is 200" do
        expect(response.status).to eq(200)
      end

      it "render show" do
        expect(response).to render_template('show')
      end
    
      context 'alien game' do
        let(:alien_game) { FactoryBot.create(:game_with_questions) }
        before { get :show, id: alien_game.id }

        it 'status is not 200 OK' do
          expect(response.status).not_to eq(200)
        end

        it 'redirect to root path' do
          expect(response).to redirect_to(root_path)
        end

        it 'it must be flash alert' do
          expect(flash[:alert]).to be 
        end
      end
    end
  end

  describe "#take_money" do
    context "when anonim" do
      before { put :take_money, id: game_w_questions.id }

      it "status is not 200 OK" do
        expect(response.status).not_to eq(200)
      end

      it "should redirect to authorization" do
        expect(response).to redirect_to(new_user_session_path)
      end

      it "it must be flash alert" do
        expect(flash[:alert]).to be
      end
    end

    context "when authorized user" do
      before do
        sign_in user
        game_w_questions.update_attribute(:current_level, 2)
        put :take_money, id: game_w_questions.id
      end

      let(:game) { assigns(:game) }

      context "before reload" do
        it "finish game return true" do
          expect(game.finished?).to be true
        end

        it "prize should return 200" do
          expect(game.prize).to eq(200)
        end
      end

      context "after reload" do
        before { user.reload }
      
        it "balance should return 200" do
          expect(user.balance).to eq(200)
        end

        it "redirect to user path" do
          expect(response).to redirect_to(user_path(user))
        end

        it "it must be flash warning" do
          expect(flash[:warning]).to be
        end
      end
    end
  end

  describe '#create' do
    context "when anonim" do
      before { post :create }

      it "status is not 200 OK" do
        expect(response.status).not_to eq(200)
      end

      it "should redirect to authorization" do
        expect(response).to redirect_to(new_user_session_path)
      end

      it "it must be flash alert" do
        expect(flash[:alert]).to be
      end
    end

    context "when authorized user" do
      before { sign_in user }

      context 'creates game' do
        before do       
          generate_questions(15)
          post :create
        end

        let(:game) { assigns(:game) }

        it "game not finished" do
          expect(game.finished?).to be false
        end

        it "should return game user" do
          expect(game.user).to eq(user)
        end

        it "redirect to game page" do
          expect(response).to redirect_to(game_path(game))
        end

        it "it must be flash notice" do
          expect(flash[:notice]).to be
        end
      end
    
    
      context 'try to create second game' do
        let(:game) { assigns(:game) }

        it 'first game not finished' do
          expect(game_w_questions.finished?).to be false
        end

        it 'new game not created' do
          request.env['HTTP_REFERER'] = 'http://test.com/'
          expect { post :create }.to change(Game, :count).by(0)
        end

        it 'new game should be nil' do
          expect(game).to be_nil
        end
      end
    end
  end

  describe '#answer' do
    context 'when anonim' do
      before { put :answer, id: game_w_questions.id }

      it "status is not 200 OK" do
        expect(response.status).not_to eq(200)
      end

      it "should redirect to authorization" do
        expect(response).to redirect_to(new_user_session_path)
      end

      it "it must be flash alert" do
        expect(flash[:alert]).to be
      end
    end

    context 'when authorized user' do
      before { sign_in user }

      context 'correct answer' do
        before do 
          put :answer, id: game_w_questions.id, 
          letter: game_w_questions.current_game_question.correct_answer_key
        end 

        let(:game) { assigns(:game) }

        it "game not finished" do
          expect(game.finished?).to be false
        end

        it "current level must be > 0" do
          expect(game.current_level).to be > 0
        end

        it "redirect to game path" do
          expect(response).to redirect_to(game_path(game))
        end
      
        it "flash empty should return true" do
          expect(flash.empty?).to be true
        end
      end

      context "wrong answer" do
        before do 
          put :answer, id: game_w_questions.id, 
          letter: (%w[a b c d] - [game_w_questions.current_game_question.correct_answer_key]).sample
        end 

        let(:game) { assigns(:game) }

        it "finish game return true" do
          expect(game.finished?).to be true
        end

        it "should return fail status" do
          expect(game.status).to eq(:fail)
        end

        it "redirect to user path" do
          expect(response).to redirect_to(user_path(game))
        end
      
        it 'it must be flash alert' do
          expect(flash.alert).to be
        end        
      end
    end
  end  
  
  describe '#help' do
    context 'when anonim' do
      before { put :help, id: game_w_questions.id }

      it "status is not 200 OK" do
        expect(response.status).not_to eq(200)
      end

      it "should redirect to authorization" do
        expect(response).to redirect_to(new_user_session_path)
      end

      it "it must be flash alert" do
        expect(flash[:alert]).to be
      end
    end

    context 'when authorized user' do
      before { sign_in user }

      context 'uses audience help' do
        it "current question's audience_help is missing from help_hash" do
          expect(game_w_questions.current_game_question.help_hash[:audience_help]).not_to be
        end

        it 'audience help not used' do
          expect(game_w_questions.audience_help_used).to be false
        end

        context 'after use help' do
          before do
            put :help, id: game_w_questions.id, 
            help_type: :audience_help
          end

          let(:game) { assigns(:game) }
      
          it 'game not finished' do
            expect(game.finished?).to be false
          end

          it 'audience help used, return true' do
            expect(game.audience_help_used).to be true
          end

          it "the current question's audience_help is present in help_hash" do
            expect(game.current_game_question.help_hash[:audience_help]).to be
          end

          it 'audience help contains keys a, b, c, d' do
            expect(game.current_game_question.help_hash[:audience_help].keys).to contain_exactly('a', 'b', 'c', 'd')
          end

          it 'redirect to game path' do
            expect(response).to redirect_to(game_path(game))
          end
        end
      end
    end
  end
end
