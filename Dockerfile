FROM ruby:3.2

WORKDIR /app

RUN apt-get update -qq && apt-get install -y \
  nodejs \
  postgresql-client

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

CMD ["rails", "s", "-b", "0.0.0.0"]