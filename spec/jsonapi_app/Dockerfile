FROM ruby:2.6.6
RUN apt-get update -qq
RUN gem update --system
RUN gem install -v 2.2.3 bundler -N
RUN mkdir /jsonapi_app
WORKDIR /jsonapi_app
ADD Gemfile /jsonapi_app/Gemfile
ADD Gemfile.lock /jsonapi_app/Gemfile.lock
RUN bundle install
ADD . /jsonapi_app
