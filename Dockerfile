FROM ruby:2.4.3-alpine
ENV LANG C.UTF-8

RUN apk update && \
    apk add \
      build-base \
      libxml2-dev \
      libxslt-dev \
      linux-headers \
      ruby-dev \
      tzdata \
      yaml \
      yaml-dev && \
    gem install bundler

WORKDIR /tmp
ADD Gemfile Gemfile
ADD Gemfile.lock Gemfile.lock
RUN bundle install

ENV APP_HOME /covfefe
RUN mkdir -p $APP_HOME
WORKDIR $APP_HOME
ADD . $APP_HOME
