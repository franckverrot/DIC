# coucou
class Foo
  # bar
  def foo; end
end
instructions = RubyVM::InstructionSequence.of(Foo.instance_method(:foo))

pp instructions.disasm
