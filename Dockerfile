FROM ruby:3.2

WORKDIR /app

RUN apt-get update -qq && apt-get install -y \
  nodejs \
  postgresql-client

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

RUN SECRET_KEY_BASE_DUMMY=1 bundle exec rails assets:precompile

CMD ["rails", "s", "-b", "0.0.0.0"]