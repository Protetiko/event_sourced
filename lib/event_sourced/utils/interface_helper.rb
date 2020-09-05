# frozen_string_literal: true

module Interface
	def method(name)
	  define_method(name) { |*args|
		  raise "Interface method #{name} not implemented."
	  }
	end
end

__END__

module Collection
	extend Interface
	method :add
	method :remove
end


col = Collection.new # <-- fails, as it should

class MyCollection
	include Collection

	def add(thing)
	  puts "Adding #{thing}"
	end
end

c1 = MyCollection.new
c1.add(1)     # <-- output 'Adding 1'
c1.remove(1)  # <-- fails with not implemented
