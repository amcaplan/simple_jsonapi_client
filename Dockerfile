FROM ruby:2.4.0
RUN apt-get update -qq
RUN gem update bundler
ENV BUNDLER_VERSION=2.0.2
RUN mkdir /simple_jsonapi_client
WORKDIR /simple_jsonapi_client
ADD . .
RUN bundle install
