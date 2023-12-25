# frozen_string_literal: true

require './src/zodiac/character_helpers'

module Zodiac
  # Base parsing class for the Zodiac language.
  class Parser
    include ::Zodiac::CharacterHelpers

    def initialize(raw_string)
      @raw_string = raw_string
      @cur_index = 0
      @tokens = []
    end

    def parse
      parse_next while @cur_index < @raw_string.size

      @tokens
    end

    private

    def parse_next
      cur = @raw_string[@cur_index]

      if symbol?(cur)
        @tokens << cur
        @cur_index += 1
      elsif letter?(cur)
        word = ''

        while (@cur_index < @raw_string.size) && alpha_num?(cur)
          word << cur
          @cur_index += 1
          cur = @raw_string[@cur_index]
        end

        @tokens << word
      else
        @cur_index += 1
      end
    end
  end
end
