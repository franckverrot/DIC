require 'rubygems'
require 'minitest/autorun'

require_relative 'bl'

class MyTest < Minitest::Test
  def setup
    @subject = Person.new("foo", 42)
    @subject.foo = 'Boo'
  end

  def test_it_speaks_to_out
    io = MiniTest::Mock.new
    io.expect :puts, false, [String]
    @subject.io = io

    res = @subject.say_name

    io.verify
  end
end
