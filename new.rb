class DIC
  @@sparkles = Hash.new
  @@cache = Hash.new
  def self.set(key, &block);@@sparkles[key] = block; end
  def self.get(key); @@cache[key] ||= @@sparkles[key].call; end
end
def register_sparkle(klass_sym); $klass_sym = klass_sym; end
def register_injection(injections); $injections = injections; end

def p(ctx)
  if ctx[:class]
    register_sparkle(ctx[:class])
  elsif ctx[:inject]
    register_injection(ctx[:inject])
  else
    raise 'blah ' + ctx
  end
end

def Object.method_added(method)
  if $injections.any? && method == :initialize
    puts "[#{$current_class}] added #{method}, $injections = #{$injections}"
    val = """
    class #{$current_class}
      class << self
        alias_method :old_new, :new
        def new(*args)
          puts \"#{$current_class}.#{method} getting injected, args = \" + args.inspect
          obj = old_new(*args)
          #{$injections.map {|i| "obj.instance_variable_set(:@#{i}, DIC.get(:#{i}))" }.join("\n")}
          obj
        end
      end
    end
    """
    puts "=" * 40
    puts val
    puts "=" * 40
    eval val
    $injections = []
  end
end

def Object.inherited(klass)
  $current_class = klass
  puts "class " + klass.inspect + " has been registered as #{$klass_sym}"
  DIC.set($klass_sym) { klass.new }
end

require 'bl'

puts "=" * 40
puts "=" * 40
DIC.set(:out) { $stdout }
DIC.get(:out).puts ":out from the DIC "
DIC.get(:taggedIO).tap { |o| puts o.__id__ }.puts 'taggedIO from the DIC'
DIC.get(:taggedIO).tap { |o| puts o.__id__ }.puts 'taggedIO from the DIC'

#DIC.get(:person) { Person.new('Franck', '29') }
#DIC.get(:program).run
