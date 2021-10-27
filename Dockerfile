ARG SHARED_SERVICES_ACCOUNT_ID
FROM ${SHARED_SERVICES_ACCOUNT_ID}.dkr.ecr.eu-west-2.amazonaws.com/admin:ruby-3-0-2-alpine3-13
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

# required for certain linting tools that read files, such as erb-lint
ENV LANG='C.UTF-8' \
  RACK_ENV=${RACK_ENV} \
  DB_HOST=${DB_HOST} \
  DB_USER=${DB_USER} \
  DB_PASS=${DB_PASS} \
  RADIUS_CONFIG_BUCKET_NAME='testconfigbucket' \
  RADIUS_CERTIFICATE_BUCKET_NAME='testcertificatebucket' \
  SECRET_KEY_BASE=${SECRET_KEY_BASE} \
  AWS_DEFAULT_REGION='eu-west-2' \
  DB_NAME=${DB_NAME}

RUN apk add --no-cache --virtual .build-deps build-base && \
  apk add --no-cache nodejs yarn mysql-dev mysql-client bash make bind shadow

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

ADD https://s3.amazonaws.com/rds-downloads/rds-combined-ca-bundle.pem $CERTDIR/

USER root
RUN chown -R $USER:$GROUP $CERTDIR &&\
  apk del .build-deps
USER $USER

RUN if [ ${RUN_PRECOMPILATION} = 'true' ]; then \
  ASSET_PRECOMPILATION_ONLY=true RAILS_ENV=production bundle exec rails assets:precompile; \
  fi

EXPOSE 3000

RUN bundle exec rake radius_attributes:fetch

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
