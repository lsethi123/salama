module Parser
  module Conditional
    include Parslet
    rule(:conditional) {
      keyword_if >> left_parenthesis >> expression.as(:conditional) >> right_parenthesis >> newline >>
        delimited_expressions(keyword_else).as(:if_true) >> 
        delimited_expressions(keyword_end).as(:if_false)
    }
  end
end