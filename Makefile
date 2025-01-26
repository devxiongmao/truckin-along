.PHONY: install
install:
	gem install bundler
	bundle install
	npm install

.PHONY: dev
dev:
	rails server

.PHONY: network_dev
network_dev:
	rails server -b 0.0.0.0

.PHONY: rubocop
rubocop:
	bin/rubocop -A


.PHONY: b-test
b-test:
	rspec

.PHONY: scan-ruby
scan-ruby:
	bin/brakeman --no-pager --skip-files script/determine_app_version.rb

.PHONY: scan-js
scan-js:
	bin/importmap audit

.PHONY: determine-app-version
determine-app-version:
	ruby script/determine_app_version.rb


.PHONY: pre-commit-check
pre-commit-check:
	$(MAKE) rubocop
	$(MAKE) scan-ruby
	$(MAKE) scan-js
	$(MAKE) b-test
