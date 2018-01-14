FROM ruby:2.4.1-stretch

COPY . /usr/src/uptime_monitor
WORKDIR /usr/src/uptime_monitor
RUN bundle install
