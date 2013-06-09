require 'set'

class Object
  def decode(params)
    params.map do |req, name|
      val = DI.value_for(name)
    end
  end

  def infect_methods(old_params)
    @@_old_params = old_params

    mod = Module.new do
      define_method :initialize do |*args|
        Kernel.puts "[Object#infect_methods] #{self}#initialize before inject"

        #if args.empty?
        #  #inject all the things
        #  puts "#{self} been passed nothing"
        #  params = decode(@@_old_params)
        #els
        if (args && old_params) && (args.count < old_params.count)
          diff   = @@_old_params.count - args.count
          start  = args.count
          finish = start+diff

          params = decode(@@_old_params[start..finish] || [])
          puts "[Object#index_methods -> injection] #{self.class}(#{@@_old_params})[#{start}, #{finish}] #{params}"
          super(*params)
        else
          # do no inject
          puts "[Object#index_methods -> no injection] #{self} been passed #{args.inspect}"
          super(*args)
        end
      end
    end
    send :prepend, mod
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
    puts "[DI#value_for] Getting value for #{name.inspect}"
    @@hash[name].call
  end

  def self.infect(class_name)
    @@infected ||= []
    if !@@infected.include?(class_name)
      @@infected << class_name
      puts "[DI#infect] Infecting #{class_name}"

      const = Kernel.const_get(class_name)
      old_initialize = const.instance_method(:initialize)
      old_params = old_initialize.parameters

      const.infect_methods(old_params)

    end
  end
end
