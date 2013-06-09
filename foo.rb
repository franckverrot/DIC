require_relative 'di'
require_relative 'bl'

DI.register(:out) { $stdout }
DI.register(:foo) { "hello world" }
DI.register(:io)  { TaggedIO.new }
DI.register(:me)  { Person.new("Franck", 28) }

Program.new.run
