# frozen_string_literal: true

require './src/zodiac/character_helpers'
require './src/zodiac/lex_error'
require './src/zodiac/string_character_iterator'
require './src/zodiac/lexer_evaluator'
require './src/zodiac/lexer_evaluator_engine'

module Zodiac
  # Base lexing class for the Zodiac language.
  #
  # Unsupported:
  #   * FANCIER STRINGS like: `%'(`Q'|`q'|`x')char any_char* char
  #   * HERE_DOC
  #   * REGEXP
  #   * '<=>'
  #   * '==='
  class Lexer
    include ::Zodiac::CharacterHelpers

    def initialize(raw_string)
      @input_iterator = StringCharacterIterator.new(raw_string)
      @lexer_evaluator_engine = LexerEvaluatorEngine.new(
        [comment_lexer, newline_lexer, op_assign_lexer, symbol_lexer, identifier_lexer, string_lexer, number_lexer],
        proc { @input_iterator.iterate }
      )
    end

    def lex
      tokens = []

      tokens << @lexer_evaluator_engine.execute(@input_iterator.peek) while @input_iterator.not_finished?

      tokens.compact.select { |token| token.is_a?(Hash) }
    end

    private

    ### Comment lexing ###
    def comment_lexer
      LexerEvaluator.new('COMMENT', method(:comment?), method(:lex_comment))
    end

    def lex_comment
      @input_iterator.take_until(proc { |val| val == "\n" })
    end

    ### Newline lexing ###
    def newline_lexer
      LexerEvaluator.new('NEWLINE', method(:newline?), method(:lex_newline))
    end

    def lex_newline
      @input_iterator.iterate
    end

    def newline?(_value)
      @input_iterator.peek == "\n"
    end

    ### Operator Assignment lexing ###
    def lex_op_assign
      @input_iterator.take_until(proc { |val| val == '=' }, after: 1)
    end

    def op_assign_lexer
      LexerEvaluator.new('OP_ASGN', method(:op_assign?), method(:lex_op_assign))
    end

    def op_assign?(_value)
      @input_iterator.op_assign_peek?
    end

    ### Symbol lexing ###
    def symbol_lexer
      LexerEvaluator.new('SYMBOL', method(:symbol?), method(:lex_symbol))
    end

    def lex_symbol
      word = @input_iterator.peek
      @input_iterator.iterate

      return word unless complex_symbol?(word, @input_iterator.peek)

      word += @input_iterator.peek
      @input_iterator.iterate

      word
    end

    ### Identifier lexing ###
    def identifier_lexer
      LexerEvaluator.new('IDENTIFIER', method(:alpha?), method(:lex_identifier))
    end

    def lex_identifier
      @input_iterator.take_until_not(method(:alpha_num?))
    end

    ### String lexing ###
    def string_lexer
      LexerEvaluator.new('STRING', method(:string_start?), method(:lex_string))
    end

    def lex_string
      raise LexError, 'String not terminated' unless @input_iterator.rest_includes?(@input_iterator.peek)

      @input_iterator.take_until(method(:string_start?), before: 1, after: 1)
    end

    ### Number lexing ###
    def number_lexer
      LexerEvaluator.new('NUMBER', method(:number?), method(:lex_number))
    end

    def lex_number
      word = @input_iterator.take_until_not(method(:number?))

      word += @input_iterator.take_until_not(method(:number?), before: 1) if @input_iterator.peek == '.'

      word
    end
  end
end
