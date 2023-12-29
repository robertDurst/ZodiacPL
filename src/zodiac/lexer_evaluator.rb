# frozen_string_literal: true

module Zodiac
  # Encapsulates lexer evaluation logic for a specific token kind.
  class LexerEvaluator
    def initialize(token_kind, condition, evaluator)
      @token_kind = token_kind
      @condition = condition
      @evaluator = evaluator
    end

    def evaluate(input)
      return nil unless @condition.call(input)

      { kind: @token_kind, value: @evaluator.call }
    end
  end
end
