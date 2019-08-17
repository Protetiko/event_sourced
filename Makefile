
.PHONY: examples
examples: example01 example02

.PHONY: example01
example01:
	@bundle exec ruby ./examples/01_simple_memory_repo/main.rb

.PHONY: example02
example02:
	@bundle exec ruby ./examples/02_simple_mongo_repo/main.rb

.PHONY: test
test:
	@bundle exec rake test
