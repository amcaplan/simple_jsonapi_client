FROM ruby:2.4.0
RUN apt-get update -qq
RUN gem update bundler
RUN mkdir /jsonapi_app
WORKDIR /jsonapi_app
ADD Gemfile /jsonapi_app/Gemfile
ADD Gemfile.lock /jsonapi_app/Gemfile.lock
RUN bundle install
ADD . /jsonapi_app
