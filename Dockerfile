FROM ruby:2.6.6
RUN apt-get update -qq
RUN gem update --system
RUN gem install -v 2.2.3 bundler -N
ENV BUNDLER_VERSION=2.2
RUN mkdir /simple_jsonapi_client
WORKDIR /simple_jsonapi_client
ADD . .
RUN bundle install
