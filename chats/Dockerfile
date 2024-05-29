FROM ruby:3.2.2

WORKDIR /app

COPY Gemfile Gemfile.lock ./

RUN apt-get update
RUN apt-get install -y cron

RUN gem install bundler && bundle install

COPY . .

EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]
