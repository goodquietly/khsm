require 'rails_helper'

RSpec.describe 'users/index', type: :view do
  before do
    assign(:users, [
      FactoryBot.build_stubbed(:user, name: 'Вадик', balance: 5000),
      FactoryBot.build_stubbed(:user, name: 'Миша', balance: 3000),
    ])

    render
  end

  it 'renders player names' do
    expect(rendered).to match 'Вадик'
    expect(rendered).to match 'Миша'
  end

  it 'renders player balances' do
    expect(rendered).to match '5 000 ₽'
    expect(rendered).to match '3 000 ₽'
  end

  it 'renders player names in right order' do
    expect(rendered).to match /Вадик.*Миша/m
  end
end
