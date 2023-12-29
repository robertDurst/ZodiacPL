# frozen_string_literal: true

module Zodiac
  # Evaluates a list of lexers and returns the first token that matches.
  class LexerEvaluatorEngine
    def initialize(lexers, default_evaluator)
      @lexers = lexers
      @default_evaluator = default_evaluator
    end

    def execute(input)
      @lexers.each do |lexer|
        token = lexer.evaluate(input)

        return token if token
      end

      @default_evaluator.call

      nil
    end
  end
end
