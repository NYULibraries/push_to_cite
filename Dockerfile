FROM ruby:2.6-alpine

# Env
ENV INSTALL_PATH /app
ENV BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_BIN=/usr/local/bundle/bin \
    GEM_HOME=/usr/local/bundle
ENV PATH="${BUNDLE_BIN}:${PATH}"
ENV USER docker
ENV BUNDLER_VERSION='2.0.1'

RUN addgroup -g 2000 $USER && \
    adduser -D -h $INSTALL_PATH -u 1000 -G $USER $USER

WORKDIR $INSTALL_PATH

# Bundle install
#COPY vendor ./vendor
COPY Gemfile Gemfile.lock ./
ARG RUN_PACKAGES=""
ARG BUILD_PACKAGES="build-base linux-headers ruby-dev"
ARG ADDL_BUILD_PACKAGES="git"
ARG BUNDLE_WITHOUT="no_docker"
RUN apk add --no-cache --update $BUILD_PACKAGES $ADDL_BUILD_PACKAGES $RUN_PACKAGES \
  && gem install bundler -v ${BUNDLER_VERSION} \
  && bundle config --local github.https true \
  && bundle install --without $BUNDLE_WITHOUT --jobs 20 --retry 5 \
  && rm -rf /root/.bundle && rm -rf /root/.gem \
  && rm -rf $BUNDLE_PATH/cache \
  && apk del $BUILD_PACKAGES $ADDL_BUILD_PACKAGES \
&& chown -R docker:docker $BUNDLE_PATH

COPY --chown=docker:docker . .

# run microscanner
ARG AQUA_MICROSCANNER_TOKEN
RUN wget -O /microscanner https://get.aquasec.com/microscanner && \
  chmod +x /microscanner && \
  /microscanner ${AQUA_MICROSCANNER_TOKEN} && \
rm -rf /microscanner

USER docker
EXPOSE 9292

CMD ./script/start.sh development
