
.PHONY: examples
examples: example01 example02

example01:
	@bundle exec ruby ./examples/01_simple_repo/main.rb

example02:
	@bundle exec ruby ./examples/02_simple_mongo_repo/main.rb
