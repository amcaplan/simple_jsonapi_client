FROM ruby:2.3.1
RUN apt-get update -qq
RUN gem update bundler
RUN mkdir /simple_jsonapi_client
WORKDIR /simple_jsonapi_client
ADD . .
RUN bundle install
