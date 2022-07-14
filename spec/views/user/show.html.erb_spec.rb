require 'rails_helper'

RSpec.describe 'users/show', type: :view do
  let!(:user) { assign(:user, FactoryBot.build_stubbed(:user, name: 'Вадик')) }

  before do
    assign(:games, [ FactoryBot.build_stubbed(:game) ])
    stub_template 'users/_game.html.erb' => 'User game goes here'

    render
  end

  context "when the user views someone else's page" do
    it 'renders user name' do
      expect(rendered).to match 'Вадик'
    end

    it 'does not renders change name and password' do
      expect(rendered).not_to match 'Сменить имя и пароль'
    end

    it 'renders snippets of the game' do
      expect(rendered).to have_content 'User game goes here'
    end
  end

  context 'when a user views their page' do
    before do
      allow(view).to receive(:current_user) { user }

      render
    end

    it 'renders change name and password' do
      expect(rendered).to match 'Сменить имя и пароль'
    end
  end
end
