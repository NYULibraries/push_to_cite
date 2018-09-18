FROM ruby:2.5.1-alpine

ENV BUILD_PACKAGES build-base git linux-headers ruby-dev

# Env
ENV INSTALL_PATH /app
ENV JEKYLL_ENV production
ENV BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_BIN=/usr/local/bundle/bin \
    GEM_HOME=/usr/local/bundle
ENV PATH="${BUNDLE_BIN}:${PATH}"
ENV USER docker

WORKDIR $INSTALL_PATH

# Bundle install
COPY Gemfile Gemfile.lock ./
COPY vendor ./vendor
RUN bundle config --global github.https true
RUN apk add --no-cache $BUILD_PACKAGES \
  && gem install bundler && bundle install --deployment --jobs 20 --retry 5 \
  && apk del $BUILD_PACKAGES

RUN addgroup -g 2000 $USER && \
    adduser -D -h $INSTALL_PATH -u 1000 -G $USER $USER
RUN chown -R docker:docker $BUNDLE_PATH

USER $USER

COPY --chown=docker:docker . .

EXPOSE 9292

CMD ["bundle", "exec", "unicorn", "-p", "9292", "-c", "./config/unicorn.rb"]
