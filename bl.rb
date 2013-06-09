Inject = nil unless defined?(DI)

class TaggedIO
  Inject; attr_accessor :out
  def puts(*args); out.puts(args); end
end

class Person
  Inject; attr_accessor :io
  Inject; attr_accessor :foo

  def initialize(name, age); @name, @age = name, age; end

  def say_name
    msg = "I am #{@name} and I am a #{@age} year-old person. I'm saying #{@foo} to you"
    io.puts msg
  end
end

class Program
  Inject; attr_accessor :me

  def run
    me.say_name
  end
end
