require 'rails_helper'

RSpec.describe 'games/game_question', type: :view do
  let(:game_question) { FactoryBot.build_stubbed :game_question }

  before(:each) do
    # Перед каждым тестом мы "сымитируем" у объекта game_question пару методов
    # Мы просто говорим тесту, что нужно веруть каждому из них
    # Подробнее про allow читайте в документации rspec
    # https://relishapp.com/rspec/rspec-mocks/v/3-4/docs
    #
    allow(game_question).to receive(:text).and_return('Кому на Руси жить хорошо?')
    allow(game_question).to receive(:variants).and_return(
      {'a' => 'Всем', 'b' => 'Никому', 'c' => 'Животным', 'd' => 'Людям'}
    )
  end

  it 'renders question text' do
    render_partial

    expect(rendered).to match 'Кому на Руси жить хорошо?'
  end

  it 'renders question text' do
    render_partial

    expect(rendered).to match 'Всем'
    expect(rendered).to match 'Никому'
    expect(rendered).to match 'Животным'
    expect(rendered).to match 'Людям'
  end

  it 'renders half variant if fifty-fifty used' do
    allow(game_question).to receive(:help_hash).and_return({fifty_fifty: ['a', 'b']})

    render_partial

    expect(rendered).to match 'Всем'
    expect(rendered).to match 'Никому'
    expect(rendered).not_to match 'Животным'
    expect(rendered).not_to match 'Людям'
  end

  private

  def render_partial
    render partial: 'games/game_question', object: game_question
  end
end
