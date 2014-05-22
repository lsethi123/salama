require_relative 'helper'

class TestPutint < MiniTest::Test
  include Fragments

  def test_putint
    @string_input = <<HERE
    putint( 42 )
HERE
    @should = [0x0,0xb0,0xa0,0xe3,0xe,0x0,0x2d,0xe9,0x2a,0x0,0xa0,0xe3,0x13,0x0,0x0,0xeb,0xe,0x0,0xbd,0xe8,0x1,0x70,0xa0,0xe3,0x0,0x0,0x0,0xef,0x0,0x40,0x2d,0xe9,0xa,0x20,0x41,0xe2,0x21,0x11,0x41,0xe0,0x21,0x12,0x81,0xe0,0x21,0x14,0x81,0xe0,0x21,0x18,0x81,0xe0,0xa1,0x11,0xa0,0xe1,0x1,0x31,0x81,0xe0,0x83,0x20,0x52,0xe0,0x1,0x10,0x81,0x52,0xa,0x20,0x82,0x42,0x30,0x20,0x82,0xe2,0x0,0x20,0xc0,0xe5,0x1,0x0,0x40,0xe2,0x0,0x0,0x51,0xe3,0xef,0xff,0xff,0x1b,0x0,0x80,0xbd,0xe8,0x0,0x40,0x2d,0xe9,0x0,0x10,0xa0,0xe1,0x24,0x0,0x8f,0xe2,0x9,0x0,0x80,0xe2,0xe9,0xff,0xff,0xeb,0x18,0x0,0x8f,0xe2,0xc,0x10,0xa0,0xe3,0x1,0x20,0xa0,0xe1,0x0,0x10,0xa0,0xe1,0x1,0x0,0xa0,0xe3,0x4,0x70,0xa0,0xe3,0x0,0x0,0x0,0xef,0x0,0x80,0xbd,0xe8,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x0]
    parse 
    write "putint"
  end
end
