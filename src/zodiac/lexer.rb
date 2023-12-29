# frozen_string_literal: true

require './src/zodiac/character_helpers'
require './src/zodiac/lex_error'
require './src/zodiac/string_character_iterator'

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
    end

    def lex
      tokens = []

      tokens << lex_next while @input_iterator.not_finished?

      tokens.compact
    end

    private

    def lexers
      [
        { token_kind: 'COMMENT', lexer: 'lex_comment', condition: proc { |top| top == '#' } },
        { token_kind: 'OP_ASGN', lexer: 'lex_op_assign', condition: proc { |_top| @input_iterator.op_assign_peek? } },
        { token_kind: 'SYMBOL', lexer: 'lex_symbol', condition: proc { |top| symbol?(top) } },
        { token_kind: 'IDENTIFIER', lexer: 'lex_identifier', condition: proc { |top|
                                                                          letter?(top) || underscore?(top)
                                                                        } },
        { token_kind: 'STRING', lexer: 'lex_string', condition: proc { |top| string_start?(top) } },
        { token_kind: 'NUMBER', lexer: 'lex_number', condition: proc { |top| number?(top) } }
      ]
    end

    def lex_next
      lexers.each do |lexer|
        next unless lexer[:condition].call(@input_iterator.peek)

        return { kind: lexer[:token_kind], value: send(lexer[:lexer]) }
      end

      # if we get here, we didn't lex anything, i.e. unrecognized character pattern
      @input_iterator.iterate

      nil
    end

    ### lexers ###

    def lex_symbol
      word = @input_iterator.peek
      @input_iterator.iterate

      return word unless complex_symbol?(word, @input_iterator.peek)

      word += @input_iterator.peek
      @input_iterator.iterate

      word
    end

    def lex_op_assign
      take_until(after: 1) { @input_iterator.peek != '=' }
    end

    def lex_string
      raise LexError, 'String not terminated' unless @input_iterator.rest_includes?(@input_iterator.peek)

      take_until(before: 1, after: 1) { !string_start?(@input_iterator.peek) }
    end

    def lex_number
      word = take_until { number?(@input_iterator.peek) }

      return word += take_until(before: 1) { number?(@input_iterator.peek) } if @input_iterator.peek == '.'

      word
    end

    def lex_identifier
      take_until { alpha_num?(@input_iterator.peek) }
    end

    def lex_comment
      take_until { @input_iterator.peek != "\n" }
    end

    ### Helpers ###
    def take_until(before: 0, after: 0)
      word = ''

      before.times { word += @input_iterator.iterate }

      word += @input_iterator.iterate while @input_iterator.not_finished? && yield

      after.times { word += @input_iterator.iterate }

      word
    end
  end
end
