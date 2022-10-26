# Кто хочет стать миллионером?!

Игра для детей от 12 до 159 лет.

Учебное приложение курса по Ruby on Rails от «Хорошего программиста». В продакшене настроено на работу с Heroku.

Приложение Ruby on rails, демонстрация тестирования приложения при помощи популярной библиотеки Rspec-rails.

### Версии программ:

```
ruby '2.5.9'

rails '~> 4.2.6'
```

## Проведенные работы:

Тестирование `Ruby on Rails` приложения про помощи библиотеки `rspec-rails`. Создание фабрик для тестов с помощью библиотеки `factory_bot_rails`. Объекты тестирования:

`models`

`controllers`

`views`

`features` при помощи `capybara` и `launchy`


### Установка программы:

Установите `Bundler`:

```
gem install bundler
```

Склонируйте репозиторий:

```
git clone https://github.com/goodquietly/khsm.git
```

Находясь в папке с игрой `cd khsm`, установите бибилиотеки:

```
bundle install
```

Выполните миграции БД

```
bundle exec rake db:migrate
```

Заполните БД тестовыми данными

```
bundle exec rake db:seed
```

Запустите тестирование программы:

```
bundle exec rspec
```

Запустите программу:

```
bundle exec rails s
```

В брайзере перейдите по ссылке:

```
http://localhost:3000
```

© http://goodprogrammer.ru
