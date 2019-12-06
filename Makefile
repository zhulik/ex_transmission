.PHONY: transmission test release deps

transmission: format deps
	mix compile

deps:
	mix local.hex --force
	mix deps.get

format:
	mix format

lint: format
	mix credo --strict

test: format
	mix test

check: lint test
