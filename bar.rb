module Bar
  def initialize
    puts "hi from bar 1"
    super
    puts "hi from bar 2"
  end

  def foo
    puts "hi from foo in Bar 1"
    super
    puts "hi from foo in Bar 2"
  end
end
class Foo
  prepend Bar
  def initialize
    puts "hi from foo"
  end

  def foo
    puts "foo in foo"
  end
end
Foo.new.foo
