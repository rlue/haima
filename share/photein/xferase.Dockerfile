# syntax = docker/dockerfile:1.1-experimental
FROM ruby:3.0.1-alpine
MAINTAINER Ryan Lue <hello@ryanlue.com>

WORKDIR /app
COPY xferase /app

ENV MEDIAINFO_XML_PARSER=nokogiri

RUN apk add --no-cache --update \
    build-base \
    exiftool \
    imagemagick \
    ffmpeg \
    mediainfo \
    optipng \
    tzdata

RUN gem install \
    photein \
    debouncer \
    rb-inotify

CMD ["./xferase"]