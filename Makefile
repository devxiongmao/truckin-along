.PHONY: install
install:
	gem install bundler
	bundle install
	pnpm install

.PHONY: dev
dev:
	redis-server & sidekiq & bin/dev

.PHONY: db-create
db-create:
	rails db:create

.PHONY: db-migrate
db-migrate:
	rails db:migrate

.PHONY: db-drop
db-drop:
	rails db:drop

.PHONY: db-seed
db-seed:
	rails db:seed

.PHONY: network_dev
network_dev:
	rails server -b 0.0.0.0

.PHONY: rubocop
rubocop:
	bin/rubocop -A

.PHONY: b-test
b-test:
	rspec

.PHONY: f-test
f-test:
	pnpm test

.PHONY: scan-ruby
scan-ruby:
	bin/brakeman --no-pager --skip-files script/determine_app_version.rb

.PHONY: scan-js
scan-js:
	bin/importmap audit

.PHONY: determine-app-version
determine-app-version:
	ruby script/determine_app_version.rb

.PHONY: generate-changelog
generate-changelog:
	ruby script/generate_changelog.rb

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

.PHONY: d_console
d_console:
	docker compose exec truckin_along rails console

.PHONY: d_logs
d_logs:
	docker compose logs -f

.PHONY: d_test
d_test:
	docker compose exec truckin_along bundle exec rspec

# Usage:
#   make e2e-test                                    # runs ALL features
#   make e2e-test FEATURE=features/hello.feature     # runs a specific feature
#   make e2e-test FEATURE=features/hello.feature:12  # runs a specific feature scenario
#   SHOW_BROWSER=true make e2e-test                  # can run all of the above using the browser

.PHONY: e2e-test
e2e-test:
	SHOW_BROWSER=$(SHOW_BROWSER) bundle exec cucumber $(FEATURE)
