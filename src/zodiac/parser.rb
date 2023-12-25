module Zodiac
  class Parser
    def initialize(raw_string)
      @raw_string = raw_string
      @cur_index = 0
      @tokens = []
    end

    def parse
      while @cur_index < @raw_string.size
        parse_next
      end

      @tokens
    end

    private

    def parse_next
      cur = @raw_string[@cur_index]

      if symbol?(cur)
        @tokens << cur
        @cur_index += 1
      elsif letter?(cur)
        word = ""

        while (@cur_index < @raw_string.size) && (alpha_num?(cur))
          word << cur
          @cur_index += 1
          cur = @raw_string[@cur_index]
        end

        @tokens << word
      else
        @cur_index += 1
      end
    end

    def symbol?(value)
      ".:[]{}\"'".include?(value)
    end

    def alpha_num?(value)
      letter?(value) || number?(value)
    end

    def letter?(value)
      value.match?(/[a-zA-Z]/)
    end

    def number?(value)
      value.match?(/[0-9]/)
    end
  end
end
