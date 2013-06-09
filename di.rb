class Object
  def self.const_missing(c)
    @next_method_will_be_injected = (c == :Inject)
  end

  def self.method_added(m)
    if @next_method_will_be_injected
      @next_method_will_be_injected = nil
      mod = Module.new do
        define_method "initialize" do |*args|
          val = DI.value_for(m)
          instance_variable_set(:"@#{m}", val)
          super(*args)
        end
      end
      prepend mod
    end
  end
end

class DI
  def self.register(name, &block)
    if !defined?(@@hash)
      @@hash = Hash.new
    end
    @@hash[name] = block
  end

  def self.value_for(name)
    @@hash[name].call
  end
end
