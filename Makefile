
.PHONY: examples
examples: example1 example2

example1:
	@bundle exec ruby ./examples/01_simple_repo/main.rb

example2:
	@bundle exec ruby ./examples/02_simple_mongo_repo/main.rb
