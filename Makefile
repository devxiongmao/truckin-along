.PHONY: install
install:
	gem install bundler
	bundle install
	npm install

.PHONY: dev
dev:
	rails server

.PHONY: migrate
migrate:
	rails db:migrate

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

.PHONY: d_init
d_init:
	docker volume create truckin_along_db_volume
	docker compose build
	docker compose up -d truckin_along_db
	
	# Wait for postgres to be ready
	sleep 5
	docker compose exec truckin_along_db psql -U postgres -c "DROP DATABASE IF EXISTS truckin_along_development;"
	docker compose exec truckin_along_db psql -U postgres -c "CREATE DATABASE truckin_along_development;"
	@echo "Docker environment initialized successfully!"

.PHONY: d_start
d_start:
	docker compose up

.PHONY: d_stop
d_stop:
	docker compose down

.PHONY: d_migrate
d_migrate:
	docker compose exec truckin_along rails db:migrate
