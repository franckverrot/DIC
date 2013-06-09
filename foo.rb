require_relative 'di'
require_relative 'bl'

DI.register(:out) { $stdout }
DI.register(:foo) { "hello world" }
DI.register(:io)  { TaggedIO.new }
DI.register(:me)  { Person.new("Franck", 28) }

DI.infect('TaggedIO')
DI.infect('Person')
#DI.infect('Program')

#Program.new.run
#Person.new.say_name
#Program.new
TaggedIO.new.puts "salut"
