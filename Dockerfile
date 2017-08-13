FROM ruby:2.3.1
RUN apt-get update -qq
RUN gem update bundler
RUN mkdir /simple_jsonapi_client
WORKDIR /simple_jsonapi_client
ADD Gemfile /simple_jsonapi_client/Gemfile
ADD simple_jsonapi_client.gemspec /simple_jsonapi_client/simple_jsonapi_client.gemspec
ADD . /simple_jsonapi_client
RUN bundle install
