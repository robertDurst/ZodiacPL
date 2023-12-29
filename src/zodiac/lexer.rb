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
      @tokens = []
      @word = ''
      @input_iterator = StringCharacterIterator.new(raw_string)
    end

    def lex
      lex_next while @input_iterator.not_finished?

      @tokens
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
      reset_lex_iteration_state

      lexers.each do |lexer|
        next unless lexer[:condition].call(@input_iterator.peek)

        send(lexer[:lexer])
        @tokens << { kind: lexer[:token_kind], value: @word }
        return true
      end

      # if we get here, we didn't lex anything, i.e. unrecognized character pattern
      @input_iterator.iterate
    end

    ### lexers ###

    def lex_symbol
      @word = @input_iterator.peek
      @input_iterator.iterate

      return unless complex_symbol?(@word, @input_iterator.peek)

      @word += @input_iterator.peek
      @input_iterator.iterate
    end

    def lex_op_assign
      continue_until_stop(after: 1) { @input_iterator.peek != '=' }
    end

    def lex_string
      unless @input_iterator.rest_includes?(@input_iterator.peek)
        raise LexError,
              'String not terminated'
      end

      continue_until_stop(before: 1, after: 1) { !string_start?(@input_iterator.peek) }
    end

    def lex_number
      continue_until_stop { number?(@input_iterator.peek) }

      return unless @input_iterator.peek == '.'

      continue_until_stop(before: 1) do
        number?(@input_iterator.peek)
      end
    end

    def lex_identifier
      continue_until_stop { alpha_num?(@input_iterator.peek) }
    end

    def lex_comment
      continue_until_stop { @input_iterator.peek != "\n" }
    end

    ### Helpers ###
    def append_word_and_iterate
      @word += @input_iterator.peek
      @input_iterator.iterate
    end

    def continue_until_stop(before: 0, after: 0)
      before.times { append_word_and_iterate }

      append_word_and_iterate while @input_iterator.not_finished? && yield

      after.times { append_word_and_iterate }

      @word
    end

    def reset_lex_iteration_state
      @word = ''
    end
  end
end
