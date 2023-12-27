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

    def lex_next
      @cur = @raw_string[@cur_index]

      # TODO: fix this unclear logic
      foo = @raw_string[@cur_index..].index(' ')
      end_index = if foo.nil?
                    @raw_string.size
                  else
                    foo + @cur_index
                  end

      if @cur == '='
        word = ''
        if !@raw_string[@cur_index + 1].nil? && @raw_string[@cur_index + 1] == '~'
          @cur_index += 2
          @tokens << { kind: 'SYMBOL', value: '=~' }
        else
          while @cur == '='
            word += @cur
            @cur_index += 1
            @cur = @raw_string[@cur_index]
          end
          @tokens << { kind: 'SYMBOL', value: word }
        end
      elsif symbol?(@cur) && !@raw_string[@cur_index + 2].nil? && @raw_string[@cur_index..@cur_index + 2] == '<=>'
        @tokens << { kind: 'SYMBOL', value: '<=>' }
        @cur_index += 3
      elsif contains_equal_sign?(@raw_string[@cur_index..end_index]) && op_assign_symbol?(@cur) && ((end_index - @cur_index) < 4)
        lex_op_assign
      elsif symbol?(@cur)
        if !@raw_string[@cur_index + 1].nil? && @raw_string[@cur_index..@cur_index + 1] == '+@'
          @tokens << { kind: 'SYMBOL', value: '+@' }
          @cur_index += 2
        elsif !@raw_string[@cur_index + 1].nil? && @raw_string[@cur_index..@cur_index + 1] == '-@'
          @tokens << { kind: 'SYMBOL', value: '-@' }
          @cur_index += 2
        elsif !@raw_string[@cur_index + 1].nil? && @raw_string[@cur_index..@cur_index + 1] == '[]'
          @tokens << { kind: 'SYMBOL', value: '[]' }
          @cur_index += 2
        else
          lex_symbol
        end
      elsif letter?(@cur) || underscore?(@cur)
        lex_identifier
      elsif string_start?(@cur)
        lex_string
      elsif number?(@cur)
        lex_number
      else
        @cur_index += 1
      end
    end

    def lex_symbol
      if @cur == @raw_string[@cur_index + 1] && double_symbol?(@raw_string[@cur_index + 1])
        @tokens << { kind: 'SYMBOL', value:  @cur + @raw_string[@cur_index + 1] }
        @cur_index += 2
      else
        @tokens << { kind: 'SYMBOL', value: @cur }
        @cur_index += 1
      end
    end

    # OP_ASGN		: `+=' | `-=' | `*=' | `/=' | `%=' | `**='
    # | `&=' | `|=' | `^=' | `<<=' | `>>='
    # | `&&=' | `||=' | '[]='
    def lex_op_assign
      end_index = @raw_string[@cur_index..].index('=') + @cur_index
      @tokens << { kind: 'OP_ASGN', value: @raw_string[@cur_index..end_index] }
      @cur_index = end_index + 1
    end

    # STRING		: `"' any_char* `"'
    # | `'' any_char* `''
    # | ``' any_char* ``'
    def lex_string
      rest_of_string = @raw_string[@cur_index + 1..]
      raise LexError, 'String not terminated' unless rest_of_string.include?(@cur)

      end_index = @raw_string[@cur_index + 1..].index(@cur) + @cur_index + 1
      @tokens << { kind: 'STRING', value: @raw_string[@cur_index..end_index] }
      @cur_index = end_index + 1
    end

    # NUMBER		: `0' | (`1'..'9') (`0'..'9')*
    # | decimal_digit decimal_digit* (`.' decimal_digit decimal_digit*)?
    def lex_number
      word = lex_single_number

      if @cur == '.'
        word += @cur
        @cur_index += 1
        @cur = @raw_string[@cur_index]
        word += lex_single_number
      end

      @tokens << { kind: 'NUMBER', value: word }
    end

    def lex_single_number
      word = ''

      while (@cur_index < @raw_string.size) && number?(@cur)
        word += @cur
        @cur_index += 1
        @cur = @raw_string[@cur_index]
      end

      word
    end

    # IDENTIFIER is the sqeunce of characters in the pattern of /[a-zA-Z_][a-zA-Z0-9_]*/.
    def lex_identifier
      word = ''

      while (@cur_index < @raw_string.size) && alpha_num?(@cur)
        word += @cur
        @cur_index += 1
        @cur = @raw_string[@cur_index]
      end

      @tokens << { kind: 'IDENTIFIER', value: word }
    end
  end
end
