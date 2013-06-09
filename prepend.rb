class DIC
  UndefinedDependencyResolution = Class.new(RuntimeError)

  @@h = Hash.new
  def self.set(key, proc_value)
    @@h[key] = proc_value
  end

  def self.get(sym)
    if prc = @@h[sym]
      prc.call
    else
      raise UndefinedDependencyResolution.new(sym)
    end
  end
end

class TaggedIO
  @@class_id = :taggedIO
  @@inject   = [:out]
  def initialize(out, date = nil)
    @out = out
    @date= date
  end

  def puts(s)
    @out.puts s.to_s
  end
end

class Logger
  @@class_id = :my_logger
  @@inject   = [:taggedIO]
#  def initialize(taggedIO)
#    @taggedIO = taggedIO
#  end

  def log(str)
    @taggedIO.puts 'From logger: ' + str
  end
end

def extract_params(params)
  out = params.map do |req, val|
    if req == :opt
      "#{val} = nil"
    else
      "#{val}"
    end
  end.join(', ')
end

def injectable?(klass)
  !!klass.module_eval('@@class_id && @@inject')
end

def get_values_for(klass)
  vals = klass.module_eval('@@inject')
end

def fabric(klass)
  parameters = klass.instance_method(:initialize).parameters
  params = parameters.map(&:last)
  opt_params = parameters.select { |req, param| req == :opt }.map(&:last)

  injected_stuff = klass.module_eval('@@inject')
  stuff_missing_in_initialize = params - injected_stuff - opt_params
  stuff_to_inject_as_iv = injected_stuff - params
  stuff_to_inject_in_initialize = params & injected_stuff

  if stuff_missing_in_initialize.any?
    raise "Missing stuff in initialize: #{stuff_missing_in_initialize.inspect}"
  end

  new_params = params.map do |param|
    if (params && injected_stuff).include?(param)
      begin
        val = DIC.get(param)
      rescue DIC::UndefinedDependencyResolution
        if opt_params.include?(param)
          val = nil
        else
          raise
        end
      end
      val
    else
      nil
    end
  end

  #puts "instantiating #{klass} with #{new_params}"
  obj = klass.new(*new_params)

  # Inject IVs
  stuff_to_inject_as_iv.each do |sym|
    obj.instance_variable_set("@#{sym}", DIC.get(sym))
  end

  obj
end

def register(klass)
  sym = klass.module_eval('@@class_id')
  DIC.set(sym, -> { fabric(klass) })
end

def inject(klass)
  if injectable?(klass)
    Kernel.puts "Yeay, #{klass} is injectable!"
    register(klass)
  end
end

inject(TaggedIO)
inject(Logger)

DIC.set(:out, -> { $stdout })
DIC.set(:date, -> { Time.now })
out = DIC.get(:out)
out.puts "from stdout!"

io = DIC.get(:taggedIO)
io.puts "from IO!!!"

logger= DIC.get(:my_logger)
logger.log 'YESSSS'
