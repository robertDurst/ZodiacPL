# frozen_string_literal: true

require './src/zodiac/character_helpers'
require './src/zodiac/lex_error'

module Zodiac
  # Base lexing class for the Zodiac language.
  #
  # Unsupported:
  #   * FANCIER STRINGS like: `%'(`Q'|`q'|`x')char any_char* char
  #   * HERE_DOC
  #   * REGEXP
  #   * '<=>'
  class Lexer
    include ::Zodiac::CharacterHelpers

    def initialize(raw_string)
      @raw_string = raw_string
      @cur_index = 0
      @tokens = []
    end

    def lex
      lex_next while @cur_index < @raw_string.size

      @tokens
    end

    private

    def lexers
      [
        { lexer: 'lex_equals_sign_prefix', condition: proc { @cur == '=' } },
        { lexer: 'lex_comment', condition: proc { @cur == '#' } },
        { lexer: 'lex_op_assign', condition: proc { op_assign? } },
        { lexer: 'lex_symbol', condition: proc { symbol?(@cur) } },
        { lexer: 'lex_identifier', condition: proc { letter?(@cur) || underscore?(@cur) } },
        { lexer: 'lex_string', condition: proc { string_start?(@cur) } },
        { lexer: 'lex_number', condition: proc { number?(@cur) } }
      ]
    end

    def lex_next
      @cur = @raw_string[@cur_index]
      @next_cur = @raw_string[@cur_index + 1]
      @word = ''

      lexers.each do |bar|
        if bar[:condition].call
          send(bar[:lexer])
          return true
        end
      end

      @cur_index += 1
    end

    ### lexers ###

    def lex_symbol
      if !@next_cur.nil? && complex_symbol?
        @tokens << { kind: 'SYMBOL', value: @cur + @next_cur }
        @cur_index += 2
      else
        @tokens << { kind: 'SYMBOL', value: @cur }
        @cur_index += 1
      end
    end

    def lex_equals_sign_prefix
      if !@next_cur.nil? && @next_cur == '~'
        @cur_index += 2
        @word = '=~'
      else
        continue_until_stop { @cur == '=' }
      end

      @tokens << { kind: 'SYMBOL', value: @word }
    end

    def lex_op_assign
      end_index = @raw_string[@cur_index..].index('=') + @cur_index
      @tokens << { kind: 'OP_ASGN', value: @raw_string[@cur_index..end_index] }
      @cur_index = end_index + 1
    end

    def lex_string
      raise LexError, 'String not terminated' unless @raw_string[@cur_index + 1..].include?(@cur)

      append_word_and_iterate
      continue_until_stop { !string_start?(@cur) }
      append_word_and_iterate

      @tokens << { kind: 'STRING', value: @word }
    end

    def lex_number
      continue_until_stop { number?(@cur) }

      # presense of '.' means it is a decimal
      lex_decimal if @cur == '.'

      @tokens << { kind: 'NUMBER', value: @word }
    end

    def lex_decimal
      append_word_and_iterate
      continue_until_stop { number?(@cur) }
    end

    def lex_identifier
      @tokens << { kind: 'IDENTIFIER', value: continue_until_stop { alpha_num?(@cur) } }
    end

    def lex_comment
      @tokens << { kind: 'COMMENT', value: continue_until_stop { @cur != "\n" } }
    end

    ### Helpers ###

    def op_assign?
      last_space_index = @raw_string[@cur_index..].index(' ')
      end_index = last_space_index.nil? ? @raw_string.size : last_space_index + @cur_index

      contains_equal_sign?(@raw_string[@cur_index..end_index]) &&
        op_assign_symbol?(@cur) && ((end_index - @cur_index) < 4)
    end

    def complex_symbol?
      %w(+@ -@ []).include?(@cur + @next_cur) || (double_symbol?(@next_cur) && @cur == @next_cur)
    end

    def append_word_and_iterate
      @word += @cur
      @cur_index += 1
      @cur = @raw_string[@cur_index]

      @word
    end

    def continue_until_stop
      append_word_and_iterate while @cur_index < @raw_string.size && yield

      @word
    end
  end
end
