FactoryBot.define do
  factory :question do
    # Ответы сделаем рандомными для красоты
    answer1 { "#{rand(2001)}" }
    answer2 { "#{rand(2001)}" }
    answer3 { "#{rand(2001)}" }
    answer4 { "#{rand(2001)}" }

    sequence(:text) { |n| "В каком году была космическая одиссея #{n}?" }

    sequence(:level) { |n| n % 15 }
  end
end
