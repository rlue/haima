# syntax = docker/dockerfile:1.1-experimental
FROM ruby:3.0.1-alpine
MAINTAINER Ryan Lue <hello@ryanlue.com>

ENV MEDIAINFO_XML_PARSER=nokogiri
ENV DEBOUNCE_WAIT=60

RUN apk add --no-cache --update \
    build-base \
    exiftool \
    imagemagick \
    ffmpeg \
    mediainfo \
    optipng \
    tzdata

RUN gem install photein

ENTRYPOINT ./xferase --inbox $INBOX --staging $STAGING --lib-orig $LIB_ORIG --lib-web $LIB_WEB --debounce $DEBOUNCE_WAIT
