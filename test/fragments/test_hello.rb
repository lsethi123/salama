require_relative 'helper'
require 'parslet/convenience'

class TestHello < MiniTest::Test
  include Fragments

  def test_hello
    @string_input = <<HERE
    putstring( "Hello Raisa, I am crystksdfkljsncjncn" )
HERE
    @should = [0x0,0xb0,0xa0,0xe3,0xe,0x0,0x2d,0xe9,0x28,0x0,0xaf,0xe3,0x2,0x0,0x0,0xeb,0xe,0x0,0xbd,0xe8,0x1,0x70,0xa0,0xe3,0x0,0x0,0x0,0xef,0x0,0x40,0x2d,0xe9,0x1,0x20,0xa0,0xe1,0x0,0x10,0xa0,0xe1,0x1,0x0,0xa0,0xe3,0x4,0x70,0xa0,0xe3,0x0,0x0,0x0,0xef,0x0,0x80,0xbd,0xe8,0x48,0x65,0x6c,0x6c,0x6f,0x20,0x52,0x61,0x69,0x73,0x61,0x2c,0x20,0x49,0x20,0x61,0x6d,0x20,0x63,0x72,0x79,0x73,0x74,0x6b,0x73,0x64,0x66,0x6b,0x6c,0x6a,0x73,0x6e,0x63,0x6a,0x6e,0x63,0x6e,0x0,0x0,0x0]
    parse 
    write "hello"
  end
end
