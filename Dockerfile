FROM ruby:2.4.2

WORKDIR /gem
COPY Gemfile* /gem/
COPY ruby_web_io.gemspec /gem/

RUN bundle install
