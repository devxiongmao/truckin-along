#!/usr/bin/env bash
# exit on error
set -o errexit

npm cache clean --force
npm install
bundle install
bundle exec rails assets:precompile
bundle exec rails assets:clean
bundle exec rails db:migrate
