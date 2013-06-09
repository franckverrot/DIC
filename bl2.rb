p(class: :taggedIO)
class TaggedIO
  p(inject: [:out])
  def initialize
    Kernel.puts "coucou"
  end

  def puts(*args); @out.puts(args); end
end

p(class: :person)
class Person
  p(inject: [:io])
  def initialize(name, age); @name, @age = name, age; end

  def say_name
    msg = "I am #{@name} and I am a #{@age} year-old person."
    @io.puts msg
  end
end

#p(class: :program)
#class Program
#  p(inject: [:person])
#  def initialize(me)
#    puts "assigning @me = #{me}"
#    @me = me
#  end
#
#  def run
#    @me.say_name
#  end
#end
