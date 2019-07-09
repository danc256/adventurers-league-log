FROM ruby:2.4.6

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs

WORKDIR /app

ADD Gemfile Gemfile.lock Rakefile ./

# Make sure we're on Bundler 2.x
RUN gem install bundler

RUN bundle install

COPY . /app

EXPOSE 3000

# Default
CMD ["rails", "s", "-b", "0.0.0.0"]
