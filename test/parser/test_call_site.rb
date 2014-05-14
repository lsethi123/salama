require_relative "helper"

class TestCallSite < MiniTest::Test
  # include the magic (setup and parse -> test method translation), see there
  include ParserHelper
    
  def test_single_argument
    @string_input = 'foo(42)'
    @parse_output = {:call_site => {:name => 'foo'},
             :argument_list    => [{:argument => {:integer => '42'} }] }
    @transform_output = Ast::CallSiteExpression.new 'foo', [Ast::IntegerExpression.new(42)]
    @parser = @parser.call_site
  end

  def test_call_site_multi
    @string_input = 'baz(42, foo)'
    @parse_output = {:call_site => {:name => 'baz' },
                     :argument_list    => [{:argument => {:integer => '42'}},
                                           {:argument => {:name => 'foo'}}]}
    @transform_output = Ast::CallSiteExpression.new 'baz', 
                           [Ast::IntegerExpression.new(42), Ast::NameExpression.new("foo") ]
    @parser = @parser.call_site
  end

  def test_call_site_string
    @string_input    = 'puts( "hello")'
    @parse_output = {:call_site => {:name => 'puts' },
                      :argument_list    => [{:argument => 
                        {:string=>[{:char=>"h"}, {:char=>"e"}, {:char=>"l"}, {:char=>"l"}, {:char=>"o"}]}}]}
    @transform_output = Ast::CallSiteExpression.new "puts", [Ast::StringExpression.new("hello")]
    @parser = @parser.call_site
  end

end