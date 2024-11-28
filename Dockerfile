FROM ruby:3.3.6-alpine3.19

ARG UID=1001
ARG GROUP=app
ARG USER=app
ARG HOME=/home/$USER
ARG APPDIR=$HOME/moj-network-access-admin
ARG CERTDIR=$HOME/cert

ARG RACK_ENV=development
ARG DB_HOST=db
ARG DB_USER=root
ARG DB_PASS=root
ARG DB_PORT=3306
ARG SECRET_KEY_BASE="fakekeybase"
ARG DB_NAME=root
ARG BUNDLE_WITHOUT=""
ARG BUNDLE_INSTALL_FLAGS=""
ARG RUN_PRECOMPILATION=true
ARG SENTRY_DSN=""
ARG CLOUDWATCH_LINK=""
ARG BUILD_DEV

# required for certain linting tools that read files, such as erb-lint
ENV LANG='C.UTF-8' \
  LC_ALL='C.UTF-8' \
  RACK_ENV=${RACK_ENV} \
  DB_HOST=${DB_HOST} \
  DB_USER=${DB_USER} \
  DB_PASS=${DB_PASS} \
  RADIUS_CONFIG_BUCKET_NAME='testconfigbucket' \
  RADIUS_CERTIFICATE_BUCKET_NAME='testcertificatebucket' \
  SECRET_KEY_BASE=${SECRET_KEY_BASE} \
  AWS_DEFAULT_REGION='eu-west-2' \
  DB_NAME=${DB_NAME} \
  CLOUDWATCH_LINK=${CLOUDWATCH_LINK}

RUN apk add --no-cache --virtual .build-deps build-base && \
  apk add --no-cache gcompat nodejs yarn mysql-dev mysql-client bash make bind shadow freeradius gcc musl-dev 

RUN if [ "${BUILD_DEV}" = "true" ] ; then \
    apk add --no-cache alpine-sdk ruby-dev; \
  fi

RUN groupadd -g $UID -o $GROUP && \
  useradd -m -u $UID -g $UID -o -s /bin/false $USER && \
  mkdir -p $APPDIR && \
  mkdir -p $CERTDIR && \
  chown -R $USER:$GROUP $HOME

USER $USER
WORKDIR $APPDIR

COPY --chown=$USER:$GROUP Gemfile Gemfile.lock .ruby-version ./
RUN bundle config set no-cache 'true' && \
  bundle install ${BUNDLE_INSTALL_FLAGS}

COPY --chown=$USER:$GROUP  package.json yarn.lock ./
RUN yarn && yarn cache clean

COPY --chown=$USER:$GROUP . $APPDIR

ADD https://truststore.pki.rds.amazonaws.com/eu-west-2/eu-west-2-bundle.pem $CERTDIR/


USER root
RUN chown -R $USER:radius /usr/share/freeradius/
RUN chown -R $USER:radius /etc/raddb
RUN chown -R $USER:$GROUP $CERTDIR &&\
  apk del .build-deps
USER $USER

RUN if [ ${RUN_PRECOMPILATION} = 'true' ]; then \
  ASSET_PRECOMPILATION_ONLY=true RAILS_ENV=development bundle exec rails assets:precompile; \
  fi

EXPOSE 3000

CMD bundle exec rails server -b 0.0.0.0
