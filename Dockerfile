FROM ruby:2.5.1-alpine
ENV LANG C.UTF-8
ENV APP_HOME /app
WORKDIR $APP_HOME
COPY . $APP_HOME
RUN apk add --update \
      build-base \
      openssl && \
    gem install bundler && \
    bundle install
